import 'package:equatable/equatable.dart';
import 'package:startlink/features/compass/domain/entities/compass_recommendation.dart';

abstract class CompassState extends Equatable {
  const CompassState();
  @override
  List<Object> get props => [];
}

class CompassInitial extends CompassState {}

class CompassLoading extends CompassState {}

class CompassLoaded extends CompassState {
  final List<CompassRecommendation> recommendations;
  const CompassLoaded(this.recommendations);
  @override
  List<Object> get props => [recommendations];
}

class CompassError extends CompassState {
  final String message;
  const CompassError(this.message);
  @override
  List<Object> get props => [message];
}
