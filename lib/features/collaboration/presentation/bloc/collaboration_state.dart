part of 'collaboration_bloc.dart';

abstract class CollaborationState extends Equatable {
  const CollaborationState();

  @override
  List<Object?> get props => [];
}

class CollaborationInitial extends CollaborationState {}

class CollaborationLoading extends CollaborationState {}

class CollaborationApplied extends CollaborationState {
  final String message;

  const CollaborationApplied(this.message);

  @override
  List<Object?> get props => [message];
}

class CollaborationLoaded extends CollaborationState {
  final List<CollaborationRequest> applications;

  const CollaborationLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

class CollaborationError extends CollaborationState {
  final String message;

  const CollaborationError(this.message);

  @override
  List<Object?> get props => [message];
}

class IdeaTeamMembersLoaded extends CollaborationState {
  final List<IdeaTeamMember> members;

  const IdeaTeamMembersLoaded(this.members);

  @override
  List<Object?> get props => [members];
}

class CollaborationActionSuccess extends CollaborationState {
  final String message;

  const CollaborationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
