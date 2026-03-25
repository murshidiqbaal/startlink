import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/admin/domain/repositories/admin_verification_repository.dart';
import 'package:startlink/features/verification/data/models/verification_models.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminVerificationRepositoryImpl implements AdminVerificationRepository {
  final SupabaseClient _supabase;

  AdminVerificationRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<UserVerification>> getPendingVerifications() async {
    return _fetchByStatus('Pending');
  }

  @override
  Future<List<UserVerification>> getApprovedVerifications() async {
    return _fetchByStatus('Approved');
  }

  @override
  Future<List<UserVerification>> getRejectedVerifications() async {
    return _fetchByStatus('Rejected');
  }

  Future<List<UserVerification>> _fetchByStatus(String status) async {
    final response = await _supabase
        .from('user_verifications')
        .select('*, profiles(full_name, email)')
        .eq('status', status)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => UserVerificationModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> approveVerification(
    String verificationId,
    String profileId,
  ) async {
    // 1. Get the verification record to know the role
    final verificationData = await _supabase
        .from('user_verifications')
        .select()
        .eq('id', verificationId)
        .maybeSingle();

    if (verificationData == null) return;
    final role = verificationData['role'] as String?;

    // 2. Update status in user_verifications
    await _supabase
        .from('user_verifications')
        .update({
          'status': 'Approved',
          'verified_at': DateTime.now().toIso8601String(),
        })
        .eq('id', verificationId);

    // 3. Award Badge
    if (role != null) {
      if (role.toLowerCase() == 'investor') {
        await _supabase.from('user_badges').insert({
          'profile_id': profileId,
          'badge_key': 'verified_investor',
          'badge_label': 'Verified Investor',
          'name': 'Verified Investor',
          'badge_description': 'Approved investor on the platform',
          'icon': 'shield_check',
        });

        await _supabase
            .from('investor_profiles')
            .update({'is_verified': true})
            .eq('profile_id', profileId);
      } else if (role.toLowerCase() == 'mentor') {
        await _supabase.from('user_badges').insert({
          'profile_id': profileId,
          'badge_key': 'verified_mentor',
          'badge_label': 'Verified Mentor',
          'name': 'Verified Mentor',
          'badge_description': 'Approved mentor on the platform',
          'icon': 'verified',
        });

        await _supabase
            .from('mentor_profiles')
            .update({'is_verified': true})
            .eq('profile_id', profileId);
      }
    }
  }

  @override
  Future<void> rejectVerification(String verificationId, String reason) async {
    // 1. Get the verification record to know the role and profileId
    final verificationData = await _supabase
        .from('user_verifications')
        .select()
        .eq('id', verificationId)
        .maybeSingle();

    final role = verificationData?['role'] as String?;
    final profileId = verificationData?['profile_id'] as String?;

    // 2. Update status in user_verifications
    await _supabase
        .from('user_verifications')
        .update({
          'status': 'Rejected',
          'metadata': {'rejection_reason': reason},
        })
        .eq('id', verificationId);

    // 3. Ensure profile is NOT verified (in case it was previously)
    if (role != null && profileId != null) {
      if (role.toLowerCase() == 'investor') {
        await _supabase
            .from('investor_profiles')
            .update({'is_verified': false})
            .eq('profile_id', profileId);
      } else if (role.toLowerCase() == 'mentor') {
        await _supabase
            .from('mentor_profiles')
            .update({'is_verified': false})
            .eq('profile_id', profileId);
      }
    }
  }
}
