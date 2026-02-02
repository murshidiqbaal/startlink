import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/achievements/domain/entities/achievement.dart';
import 'package:startlink/features/achievements/domain/repositories/achievement_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final SupabaseClient _supabase;

  AchievementRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<Achievement>> getAchievements(String userId) async {
    final response = await _supabase
        .from('user_achievements')
        .select()
        .eq('profile_id', userId)
        .order('awarded_at', ascending: false);

    return (response as List)
        .map(
          (e) => Achievement(
            id: e['id'],
            key: e['achievement_key'],
            title: e['title'],
            description: e['description'] ?? '',
            iconUrl: e['icon_url'],
            awardedAt: DateTime.parse(e['awarded_at']),
          ),
        )
        .toList();
  }

  @override
  Future<void> evaluateAndAward(String userId, String eventKey) async {
    // 1. Fetch Profile State (Counts, Status)
    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    // 2. Rule Engine Logic (Client-side for MVP, ideally Server-side)
    if (eventKey == 'publish_idea') {
      // First Spark Rule: Check if first idea
      final ideasCount = await _supabase
          .from('ideas')
          .count()
          .eq('owner_id', userId);
      if (ideasCount == 1) {
        // Current count 1 means first one just added
        await _award(
          userId,
          'first_idea',
          'First Spark',
          'Published your first idea',
          'Innovator',
        );
      }
    }

    if (eventKey == 'verification_approved') {
      await _award(
        userId,
        'verified_user',
        'Verified Member',
        'Identity verified successfully',
        'All',
      );
    }

    if (eventKey == 'profile_complete' &&
        (profile['profile_completion'] ?? 0) >= 80) {
      await _award(
        userId,
        'profile_complete',
        'Profile Builder',
        'Completed 80% of profile',
        'All',
      );
    }
  }

  Future<void> _award(
    String userId,
    String key,
    String title,
    String desc,
    String role,
  ) async {
    await _supabase.rpc(
      'award_achievement',
      params: {
        'target_profile_id': userId,
        'target_role': role,
        'key_text': key,
        'title_text': title,
        'desc_text': desc,
        'icon_path': null,
      },
    );
  }
}
