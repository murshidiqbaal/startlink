part of 'pitch_health_bloc.dart';

abstract class PitchHealthState extends Equatable {
  const PitchHealthState();
  @override
  List<Object> get props => [];
}

class PitchHealthInitial extends PitchHealthState {}

class PitchHealthLoading extends PitchHealthState {}

class PitchHealthLoaded extends PitchHealthState {
  final PitchScore score;

  const PitchHealthLoaded(this.score);

  @override
  List<Object> get props => [score];
}

class PitchHealthError extends PitchHealthState {
  final String message;
  const PitchHealthError(this.message);
}
