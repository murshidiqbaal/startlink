import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';

abstract class MatchingEvent extends Equatable {
  const MatchingEvent();
  @override
  List<Object> get props => [];
}

class LoadMatches extends MatchingEvent {
  final Idea idea;
  const LoadMatches(this.idea);
  @override
  List<Object> get props => [idea];
}
