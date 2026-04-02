import 'package:equatable/equatable.dart';
import '../../../domain/entities/pitch_request.dart';

abstract class PitchState extends Equatable {
  const PitchState();

  @override
  List<Object?> get props => [];
}

class PitchInitial extends PitchState {}
class PitchLoading extends PitchState {}

class PitchRequestStatusLoaded extends PitchState {
  final PitchRequest? request;
  const PitchRequestStatusLoaded(this.request);

  @override
  List<Object?> get props => [request];
}

class PitchRequestSuccess extends PitchState {
  final PitchRequest request;
  const PitchRequestSuccess(this.request);

  @override
  List<Object?> get props => [request];
}

class InvestorPitchRequestsLoaded extends PitchState {
  final List<PitchRequest> requests;
  const InvestorPitchRequestsLoaded(this.requests);

  @override
  List<Object?> get props => [requests];
}

class PitchError extends PitchState {
  final String message;
  const PitchError(this.message);

  @override
  List<Object?> get props => [message];
}
