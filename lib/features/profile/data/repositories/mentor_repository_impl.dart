import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/mentor_repository.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/verification/data/models/verification_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class MentorRepositoryImpl implements MentorRepository {
  final SupabaseClient _supabase;

  MentorRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<MentorProfile?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('mentor_profiles')
          .select('*')
          .eq('profile_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return MentorProfileModel.fromJson(response);
    } catch (e) {
      debugPrint('MentorRepo: Error fetching profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateProfile(MentorProfile profile) async {
    try {
      // UPSERT as requested
      await _supabase.from('mentor_profiles').upsert({
        'profile_id': profile.profileId,
        'expertise': profile.expertise,
        'years_experience': profile.yearsExperience,
        'bio': profile.bio,
        'linkedin_url': profile.linkedinUrl,
        'availability': profile.availability,
        'profile_completion': profile.profileCompletion,
        'updated_at': DateTime.now().toIso8601String(),
      });

      // AUTO VERIFICATION REQUEST
      if (profile.profileCompletion >= 80) {
        await submitVerification(profile.profileId);
      }
    } catch (e) {
      debugPrint('MentorRepo: Error updating profile: $e');
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
          .eq('role', 'mentor')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (existing != null && existing['status'] == 'pending') return;

      await _supabase.from('user_verifications').upsert({
        'profile_id': userId,
        'role': 'mentor',
        'verification_type': 'profile_review',
        'status': 'pending'
      });
    } catch (e) {
      debugPrint('MentorRepo: Error submitting verification: $e');
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
          .eq('role', 'mentor')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return UserVerificationModel.fromJson(response);
    } catch (e) {
      debugPrint('MentorRepo: Error fetching verification status: $e');
      return null;
    }
  }
}
