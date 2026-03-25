import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';

class CollaborationRequestModel extends CollaborationRequest {
  const CollaborationRequestModel({
    required super.id,
    required super.ideaId,
    required super.applicantId,
    required super.innovatorId,
    required super.roleApplied,
    super.message,
    super.status,
    required super.createdAt,
    super.ideaTitle,
    super.applicant,
    super.innovator,
  });

  factory CollaborationRequestModel.fromJson(Map<String, dynamic> json) {
    return CollaborationRequestModel(
      id: json['request_id'] as String,
      ideaId: json['idea_id'] as String,
      applicantId: json['applicant_id'] as String,
      innovatorId: json['innovator_id'] as String,
      roleApplied: json['role_applied'] as String,
      message: json['message'] as String?,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      ideaTitle: (json['ideas'] as Map?)?['title'],
      applicant: json['applicant'] as Map<String, dynamic>?,
      innovator: json['innovator'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'request_id': id,
      'idea_id': ideaId,
      'applicant_id': applicantId,
      'innovator_id': innovatorId,
      'role_applied': roleApplied,
      'message': message,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'ideaTitle': ideaTitle,
      'applicant': applicant,
      'innovator': innovator,
    };
  }
}
