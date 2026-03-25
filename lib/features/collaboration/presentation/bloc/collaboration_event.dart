part of 'collaboration_bloc.dart';

abstract class CollaborationEvent extends Equatable {
  const CollaborationEvent();

  @override
  List<Object?> get props => [];
}

class ApplyCollaboration extends CollaborationEvent {
  final String ideaId;
  final String innovatorId;
  final String roleApplied;
  final String message;

  const ApplyCollaboration({
    required this.ideaId,
    required this.innovatorId,
    required this.roleApplied,
    required this.message,
  });

  @override
  List<Object?> get props => [ideaId, innovatorId, roleApplied, message];
}

class LoadIdeaApplications extends CollaborationEvent {
  final String ideaId;

  const LoadIdeaApplications(this.ideaId);

  @override
  List<Object?> get props => [ideaId];
}

class AcceptCollaborationRequest extends CollaborationEvent {
  final String requestId;

  const AcceptCollaborationRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectCollaborationRequest extends CollaborationEvent {
  final String requestId;

  const RejectCollaborationRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class FetchMyCollaborations extends CollaborationEvent {}

class FetchReceivedCollaborations extends CollaborationEvent {}

class FetchIdeaTeamMembers extends CollaborationEvent {
  final String ideaId;

  const FetchIdeaTeamMembers(this.ideaId);

  @override
  List<Object?> get props => [ideaId];
}

class UpdateCollaborationStatus extends CollaborationEvent {
  final String collaborationId;
  final String status;

  const UpdateCollaborationStatus({
    required this.collaborationId,
    required this.status,
  });

  @override
  List<Object?> get props => [collaborationId, status];
}
