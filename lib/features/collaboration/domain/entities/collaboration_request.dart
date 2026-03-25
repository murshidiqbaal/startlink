import 'package:equatable/equatable.dart';

class CollaborationRequest extends Equatable {
  final String id;
  final String ideaId;
  final String applicantId;
  final String innovatorId;
  final String roleApplied;
  final String? message;
  final String status;
  final DateTime createdAt;

  // UI Helper fields (populated via joins)
  final String? ideaTitle;
  final Map<String, dynamic>? applicant;
  final Map<String, dynamic>? innovator;

  const CollaborationRequest({
    required this.id,
    required this.ideaId,
    required this.applicantId,
    required this.innovatorId,
    required this.roleApplied,
    this.message,
    this.status = 'pending',
    required this.createdAt,
    this.ideaTitle,
    this.applicant,
    this.innovator,
  });

  @override
  List<Object?> get props => [
        id,
        ideaId,
        applicantId,
        innovatorId,
        roleApplied,
        message,
        status,
        createdAt,
        ideaTitle,
        applicant,
        innovator,
      ];
}
