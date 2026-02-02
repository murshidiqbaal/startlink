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
        .select()
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
    await _supabase
        .from('user_verifications')
        .update({
          'status': 'Approved',
          'verified_at': DateTime.now().toIso8601String(),
        })
        .eq('id', verificationId);

    // Trigger Badge Award (simplified; normally a trigger or separate call)
    // We can use the VerificationRepository or direct DB call here since this is Admin repo
    // For now, let's just ensure the status is updated.
    // The Trust Score engine will pick this up when the user profile loads or via a trigger.
  }

  @override
  Future<void> rejectVerification(String verificationId, String reason) async {
    await _supabase
        .from('user_verifications')
        .update({
          'status': 'Rejected',
          'metadata': {'rejection_reason': reason},
        })
        .eq('id', verificationId);
  }
}
