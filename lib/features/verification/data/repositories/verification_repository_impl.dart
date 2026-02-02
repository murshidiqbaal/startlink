import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/verification/data/models/verification_models.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/verification/domain/repositories/verification_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  final SupabaseClient _supabase;

  VerificationRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<UserVerification>> getVerifications(String profileId) async {
    try {
      final response = await _supabase
          .from('user_verifications')
          .select()
          .eq('profile_id', profileId);
      return (response as List)
          .map((e) => UserVerificationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch verifications: $e');
    }
  }

  @override
  Future<List<UserBadge>> getBadges(String profileId) async {
    try {
      final response = await _supabase
          .from('user_badges')
          .select()
          .eq('profile_id', profileId);
      return (response as List).map((e) => UserBadgeModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch badges: $e');
    }
  }

  @override
  Future<void> requestVerification(
    String profileId,
    String role,
    String type,
  ) async {
    try {
      // Check if already pending/approved to avoid dupes
      final existing = await _supabase
          .from('user_verifications')
          .select()
          .eq('profile_id', profileId)
          .eq('verification_type', type)
          .eq('role', role)
          .maybeSingle();

      if (existing != null) {
        // If rejected, maybe allow re-request? For now, do nothing if pending/approved.
        if (existing['status'] == 'Rejected') {
          // Re-open logic could go here
          await _supabase
              .from('user_verifications')
              .update({'status': 'Pending'})
              .eq('id', existing['id']);
        }
        return;
      }

      await _supabase.from('user_verifications').insert({
        'profile_id': profileId,
        'role': role,
        'verification_type': type,
        'status': 'Pending', // Default
      });
    } catch (e) {
      throw Exception('Failed to request verification: $e');
    }
  }

  @override
  Future<void> awardBadge(
    String profileId,
    String badgeKey,
    String label,
    String description,
  ) async {
    try {
      final existing = await _supabase
          .from('user_badges')
          .select()
          .eq('profile_id', profileId)
          .eq('badge_key', badgeKey)
          .maybeSingle();
      if (existing != null) return; // Already awarded

      await _supabase.from('user_badges').insert({
        'profile_id': profileId,
        'badge_key': badgeKey,
        'badge_label': label,
        'badge_description': description,
        // 'icon' can be mapped in UI based on key or passed here
      });
    } catch (e) {
      print('Error awarding badge: $e'); // Fail silent for background logic
    }
  }
}
