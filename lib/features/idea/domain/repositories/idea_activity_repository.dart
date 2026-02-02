import 'package:startlink/features/idea/domain/entities/idea_activity_log.dart';

abstract class IdeaActivityRepository {
  Future<List<IdeaActivityLog>> getActivityLogs(String ideaId);
  Future<void> logActivity({
    required String ideaId,
    required String eventType,
    required String title,
    String? description,
    String? actorProfileId,
    String? actorRole,
    Map<String, dynamic>? metadata,
  });
}
