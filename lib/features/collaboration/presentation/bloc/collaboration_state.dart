part of 'collaboration_bloc.dart';

abstract class CollaborationState extends Equatable {
  const CollaborationState();

  @override
  List<Object> get props => [];
}

class CollaborationInitial extends CollaborationState {}

class CollaborationLoading extends CollaborationState {}

class CollaborationLoaded extends CollaborationState {
  final List<Collaboration> collaborations;

  const CollaborationLoaded(this.collaborations);

  @override
  List<Object> get props => [collaborations];
}

class CollaborationActionSuccess extends CollaborationState {
  final String message;

  const CollaborationActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CollaborationError extends CollaborationState {
  final String message;

  const CollaborationError(this.message);

  @override
  List<Object> get props => [message];
}
