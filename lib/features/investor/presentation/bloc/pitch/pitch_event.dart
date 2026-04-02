import 'package:equatable/equatable.dart';
import '../../../domain/entities/pitch_request.dart';

abstract class PitchEvent extends Equatable {
  const PitchEvent();

  @override
  List<Object?> get props => [];
}

class RequestPitch extends PitchEvent {
  final String ideaId;
  final String investorId;
  final String innovatorId;

  const RequestPitch({
    required this.ideaId,
    required this.investorId,
    required this.innovatorId,
  });

  @override
  List<Object?> get props => [ideaId, investorId, innovatorId];
}

class FetchPitchRequestStatus extends PitchEvent {
  final String ideaId;
  final String investorId;

  const FetchPitchRequestStatus({
    required this.ideaId,
    required this.investorId,
  });

  @override
  List<Object?> get props => [ideaId, investorId];
}

class UpdatePitchStatus extends PitchEvent {
  final String requestId;
  final PitchStatus status;
  final String? pitchDeckUrl;

  const UpdatePitchStatus({
    required this.requestId,
    required this.status,
    this.pitchDeckUrl,
  });

  @override
  List<Object?> get props => [requestId, status, pitchDeckUrl];
}

class LoadInvestorPitchRequests extends PitchEvent {
  final String investorId;
  const LoadInvestorPitchRequests(this.investorId);

  @override
  List<Object?> get props => [investorId];
}
