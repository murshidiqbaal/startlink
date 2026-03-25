import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/idea/data/models/idea_activity_log_model.dart';
import 'package:startlink/features/idea/domain/entities/idea_activity_log.dart';
import 'package:startlink/features/idea/domain/repositories/idea_activity_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdeaActivityRepositoryImpl implements IdeaActivityRepository {
  final SupabaseClient _supabase;

  IdeaActivityRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<IdeaActivityLog>> getActivityLogs(String ideaId) async {
    try {
      final response = await _supabase
          .from('idea_activity_logs')
          .select()
          .eq('idea_id', ideaId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => IdeaActivityLogModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch activity logs: $e');
    }
  }

  @override
  Future<void> logActivity({
    required String ideaId,
    required String eventType,
    required String title,
    String? description,
    String? actorProfileId,
    String? actorRole,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final log = {
        'idea_id': ideaId,
        'event_type': eventType,
        'title': title,
        'description': description,
        'actor_profile_id': actorProfileId,
        'actor_role': actorRole,
        'metadata': metadata ?? {},
      };

      await _supabase.from('idea_activity_logs').insert(log);
    } catch (e) {
      throw Exception('Failed to log activity: $e');
    }
  }
}
