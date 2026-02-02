import 'package:equatable/equatable.dart';
import 'package:startlink/features/matching/domain/entities/idea_match.dart';

abstract class MatchingState extends Equatable {
  const MatchingState();
  @override
  List<Object> get props => [];
}

class MatchingInitial extends MatchingState {}

class MatchingLoading extends MatchingState {}

class MatchingLoaded extends MatchingState {
  final List<IdeaMatch> mentors;
  final List<IdeaMatch> collaborators;
  const MatchingLoaded({required this.mentors, required this.collaborators});
  @override
  List<Object> get props => [mentors, collaborators];
}

class MatchingError extends MatchingState {
  final String message;
  const MatchingError(this.message);
  @override
  List<Object> get props => [message];
}
