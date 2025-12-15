import 'package:equatable/equatable.dart';

class Collaboration extends Equatable {
  final String id;
  final String ideaId;
  final String collaboratorId;
  final String innovatorId;
  final String roleApplied;
  final String message;
  final String status;
  final DateTime appliedAt;
  final DateTime updatedAt;

  // Optional: Expanded fields for UI (joined)
  final String? ideaTitle;
  final String? collaboratorName;
  final String? collaboratorAvatarUrl;
  final String? collaboratorHeadline;

  const Collaboration({
    required this.id,
    required this.ideaId,
    required this.collaboratorId,
    required this.innovatorId,
    required this.roleApplied,
    required this.message,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.ideaTitle,
    this.collaboratorName,
    this.collaboratorAvatarUrl,
    this.collaboratorHeadline,
  });

  @override
  List<Object?> get props => [
    id,
    ideaId,
    collaboratorId,
    innovatorId,
    roleApplied,
    message,
    status,
    appliedAt,
    updatedAt,
    ideaTitle,
    collaboratorName,
    collaboratorAvatarUrl,
    collaboratorHeadline,
  ];
}
