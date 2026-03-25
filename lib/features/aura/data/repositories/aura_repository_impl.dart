import 'package:flutter/foundation.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/aura/domain/entities/aura_activity.dart';
import 'package:startlink/features/aura/domain/repositories/aura_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuraRepositoryImpl implements AuraRepository {
  final SupabaseClient _supabase;

  AuraRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _supabase.rpc(
        'award_aura_points',
        params: {
          'target_profile_id': userId,
          'points_to_add': points,
          'reason_text': reason,
          'metadata_json': metadata ?? {},
        },
      );
    } catch (e) {
      // Log error but generally don't block user flow for gamification failure
      debugPrint('Aura award failed: $e');
    }
  }

  @override
  Future<int> getTotalAura(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('aura_points')
        .eq('id', userId)
        .maybeSingle();

    return response?['aura_points'] as int? ?? 0;
  }

  @override
  Future<List<AuraActivity>> getHistory(String userId) async {
    final response = await _supabase
        .from('user_aura')
        .select()
        .eq('profile_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (e) => AuraActivity(
            id: e['id'],
            points: e['points'],
            reason: e['reason'],
            createdAt: DateTime.parse(e['created_at']),
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getLeaderboard(String role) async {
    final response = await _supabase
        .from('profiles')
        .select('id, full_name, role, aura_points, avatar_url')
        .eq('role', role)
        .order('aura_points', ascending: false)
        .limit(20);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>?> getWeeklySummary(String userId) async {
    final response = await _supabase
        .from('aura_weekly_summary')
        .select()
        .eq('profile_id', userId)
        .order('week_start', ascending: false) // Latest week first
        .limit(1)
        .maybeSingle();

    return response;
  }

  @override
  Future<void> syncRetroactivePoints(String userId) async {
    try {
      // 1. Fetch relevant user data
      final profileResponse = await _supabase
          .from('profiles')
          .select('is_verified, profile_completion')
          .eq('id', userId)
          .maybeSingle();

      final ideasResponse = await _supabase
          .from('ideas')
          .select('id')
          .eq('owner_id', userId);

      final ideaCount = (ideasResponse as List).length;

      final historyResponse = await _supabase
          .from('user_aura')
          .select('reason, points')
          .eq('profile_id', userId);

      final history = List<Map<String, dynamic>>.from(historyResponse as List);

      // 2. Define Rules & Calculate Expected Points
      const int pointsPerIdea = 50;
      const int pointsForVerification = 500;
      const int pointsForProfileComp = 100;

      int expectedIdeaPoints = ideaCount * pointsPerIdea;
      int expectedVerificationPoints = (profileResponse?['is_verified'] == true)
          ? pointsForVerification
          : 0;
      int expectedProfilePoints =
          ((profileResponse?['profile_completion'] ?? 0) >= 80)
          ? pointsForProfileComp
          : 0;

      // 3. Calculate Already Awarded Points
      int awardedIdeaPoints = 0;
      int awardedVerificationPoints = 0;
      int awardedProfilePoints = 0;

      for (var entry in history) {
        final reason = entry['reason'] as String;
        final points = entry['points'] as int;

        if (reason.contains('Idea Created') ||
            reason.contains('Retroactive Idea')) {
          awardedIdeaPoints += points;
        } else if (reason.contains('Identity Verified')) {
          awardedVerificationPoints += points;
        } else if (reason.contains('Profile Completion')) {
          awardedProfilePoints += points;
        }
      }

      // 4. Determine missing points
      int missingIdeaPoints = expectedIdeaPoints - awardedIdeaPoints;
      int missingVerificationPoints =
          expectedVerificationPoints - awardedVerificationPoints;
      int missingProfilePoints = expectedProfilePoints - awardedProfilePoints;

      // 5. Award missing points (if positive)
      if (missingIdeaPoints > 0) {
        await awardPoints(
          userId: userId,
          points: missingIdeaPoints,
          reason:
              'Retroactive Idea Sync: ${missingIdeaPoints ~/ pointsPerIdea} ideas',
        );
      }

      if (missingVerificationPoints > 0) {
        await awardPoints(
          userId: userId,
          points: missingVerificationPoints,
          reason: 'Retroactive: Identity Verified',
        );
      }

      if (missingProfilePoints > 0) {
        await awardPoints(
          userId: userId,
          points: missingProfilePoints,
          reason: 'Retroactive: Profile Completion',
        );
      }
    } catch (e) {
      debugPrint('Error syncing retroactive points: $e');
    }
  }
}
