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
      print('Aura award failed: $e');
    }
  }

  @override
  Future<int> getTotalAura(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select('aura_points')
        .eq('id', userId)
        .single();

    return response['aura_points'] as int? ?? 0;
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
}
