import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/investor_repository.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/verification/data/models/verification_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class InvestorRepositoryImpl implements InvestorRepository {
  final SupabaseClient _supabase;

  InvestorRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<InvestorProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('investor_profiles')
          .select('*, profiles(about)')
          .eq('profile_id', userId)
          .maybeSingle();

      if (response == null) return null;

      final json = Map<String, dynamic>.from(response);
      if (json['profiles'] != null) {
        json['bio'] = json['profiles']['about'];
      }

      return InvestorProfileModel.fromJson(json);
    } catch (e) {
      debugPrint('InvestorRepo: Error fetching profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(InvestorProfile profile) async {
    try {
      // UPSERT as requested
      await _supabase.from('investor_profiles').upsert({
        'profile_id': profile.profileId,
        'investment_focus': profile.investmentFocus,
        'ticket_size_min': profile.ticketSizeMin,
        'ticket_size_max': profile.ticketSizeMax,
        'preferred_stage': profile.preferredStage,
        'organization_name': profile.organizationName,
        'linkedin_url': profile.linkedinUrl,
        'profile_completion': profile.profileCompletion,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Sync bio to profiles table if present
      if (profile.bio != null) {
        await _supabase
            .from('profiles')
            .update({'about': profile.bio})
            .eq('id', profile.profileId);
      }

      // AUTO VERIFICATION REQUEST
      if (profile.profileCompletion >= 80) {
        await submitVerification(profile.profileId);
      }
    } catch (e) {
      debugPrint('InvestorRepo: Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> submitVerification(String userId) async {
    try {
      // Check for existing request to avoid duplicates
      final existing = await _supabase
          .from('user_verifications')
          .select()
          .eq('profile_id', userId)
          .eq('role', 'investor')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null) return;

      await _supabase.from('user_verifications').upsert({
        'profile_id': userId,
        'role': 'investor',
        'verification_type': 'profile_review',
        'status': 'pending'
      });
    } catch (e) {
      debugPrint('InvestorRepo: Error submitting verification: $e');
      rethrow;
    }
  }

  @override
  Future<UserVerification?> getVerificationStatus(String userId) async {
    try {
      final response = await _supabase
          .from('user_verifications')
          .select('*')
          .eq('profile_id', userId)
          .eq('role', 'investor')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return UserVerificationModel.fromJson(response);
    } catch (e) {
      debugPrint('InvestorRepo: Error fetching verification status: $e');
      return null;
    }
  }
}
