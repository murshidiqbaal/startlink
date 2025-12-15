import 'package:startlink/features/collaboration/domain/entities/collaboration.dart';

class CollaborationModel extends Collaboration {
  const CollaborationModel({
    required super.id,
    required super.ideaId,
    required super.collaboratorId,
    required super.innovatorId,
    required super.roleApplied,
    required super.message,
    required super.status,
    required super.appliedAt,
    required super.updatedAt,
    super.ideaTitle,
    super.collaboratorName,
    super.collaboratorAvatarUrl,
    super.collaboratorHeadline,
  });

  factory CollaborationModel.fromJson(Map<String, dynamic> json) {
    return CollaborationModel(
      id: json['id'] as String,
      ideaId: json['idea_id'] as String,
      collaboratorId: json['collaborator_id'] as String,
      innovatorId: json['innovator_id'] as String,
      roleApplied: json['role_applied'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // Handle potential joins or expanded views if Supabase returns joined data
      ideaTitle: json['ideas'] != null ? json['ideas']['title'] : null,
      collaboratorName: json['profiles'] != null
          ? json['profiles']['full_name']
          : null,
      collaboratorAvatarUrl: json['profiles'] != null
          ? json['profiles']['avatar_url']
          : null,
      collaboratorHeadline: json['profiles'] != null
          ? json['profiles']['headline']
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idea_id': ideaId,
      'collaborator_id': collaboratorId,
      'innovator_id': innovatorId,
      'role_applied': roleApplied,
      'message': message,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
