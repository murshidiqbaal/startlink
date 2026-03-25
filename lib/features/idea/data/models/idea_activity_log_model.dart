import 'package:startlink/features/idea/domain/entities/idea_activity_log.dart';

class IdeaActivityLogModel extends IdeaActivityLog {
  const IdeaActivityLogModel({
    required super.id,
    required super.ideaId,
    super.actorProfileId,
    super.actorRole,
    required super.eventType,
    required super.title,
    super.description,
    super.metadata,
    required super.createdAt,
  });

  factory IdeaActivityLogModel.fromJson(Map<String, dynamic> json) {
    return IdeaActivityLogModel(
      id: json['id'] as String,
      ideaId: json['idea_id'] as String,
      actorProfileId: json['actor_profile_id'] as String?,
      actorRole: json['actor_role'] as String?,
      eventType: json['event_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idea_id': ideaId,
      'actor_profile_id': actorProfileId,
      'actor_role': actorRole,
      'event_type': eventType,
      'title': title,
      'description': description,
      'metadata': metadata,
      // created_at is usually server generated, but can be passed if needed
    };
  }
}
