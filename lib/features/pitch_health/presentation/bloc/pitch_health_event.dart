part of 'pitch_health_bloc.dart';

abstract class PitchHealthEvent extends Equatable {
  const PitchHealthEvent();
  @override
  List<Object> get props => [];
}

class AnalyzePitch extends PitchHealthEvent {
  final String title;
  final String description;

  const AnalyzePitch({required this.title, required this.description});

  @override
  List<Object> get props => [title, description];
}
