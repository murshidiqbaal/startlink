part of 'idea_dna_bloc.dart';

abstract class IdeaDnaState extends Equatable {
  const IdeaDnaState();

  @override
  List<Object> get props => [];
}

class IdeaDnaInitial extends IdeaDnaState {}

class IdeaDnaLoading extends IdeaDnaState {}

class IdeaDnaLoaded extends IdeaDnaState {
  final IdeaDna dna;

  const IdeaDnaLoaded(this.dna);

  @override
  List<Object> get props => [dna];
}

class IdeaDnaError extends IdeaDnaState {
  final String message;

  const IdeaDnaError(this.message);

  @override
  List<Object> get props => [message];
}
