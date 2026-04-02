import '../entities/pitch_request.dart';

abstract class PitchRepository {
  Future<PitchRequest?> getPitchRequestForIdea(String ideaId, String investorId);
  Future<void> requestPitch({
    required String ideaId,
    required String investorId,
    required String innovatorId,
  });
  Future<List<PitchRequest>> fetchIncomingPitchRequests(String innovatorId);
  Future<void> updatePitchRequestStatus({
    required String requestId,
    required PitchStatus status,
    String? pitchDeckUrl,
  });
  Future<List<PitchRequest>> fetchInvestorPitchRequests(String investorId);
}
