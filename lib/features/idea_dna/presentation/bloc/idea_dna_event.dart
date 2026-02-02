part of 'idea_dna_bloc.dart';

abstract class IdeaDnaEvent extends Equatable {
  const IdeaDnaEvent();

  @override
  List<Object> get props => [];
}

class FetchIdeaDna extends IdeaDnaEvent {
  final String ideaId;

  const FetchIdeaDna(this.ideaId);

  @override
  List<Object> get props => [ideaId];
}
