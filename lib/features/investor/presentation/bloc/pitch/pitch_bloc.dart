import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/pitch_repository.dart';
import 'pitch_event.dart';
import 'pitch_state.dart';

class PitchBloc extends Bloc<PitchEvent, PitchState> {
  final PitchRepository _repository;

  PitchBloc({required PitchRepository repository})
      : _repository = repository,
        super(PitchInitial()) {
    on<RequestPitch>(_onRequestPitch);
    on<FetchPitchRequestStatus>(_onFetchStatus);
    on<UpdatePitchStatus>(_onUpdateStatus);
    on<LoadInvestorPitchRequests>(_onLoadInvestorRequests);
  }

  Future<void> _onLoadInvestorRequests(LoadInvestorPitchRequests event, Emitter<PitchState> emit) async {
    emit(PitchLoading());
    try {
      final requests = await _repository.fetchInvestorPitchRequests(event.investorId);
      emit(InvestorPitchRequestsLoaded(requests));
    } catch (e) {
      emit(PitchError(e.toString()));
    }
  }

  Future<void> _onRequestPitch(RequestPitch event, Emitter<PitchState> emit) async {
    emit(PitchLoading());
    try {
      await _repository.requestPitch(
        ideaId: event.ideaId,
        investorId: event.investorId,
        innovatorId: event.innovatorId,
      );
      final request = await _repository.getPitchRequestForIdea(event.ideaId, event.investorId);
      if (request != null) {
        emit(PitchRequestSuccess(request));
      } else {
        emit(const PitchError('Failed to retrieve request after creation.'));
      }
    } catch (e) {
      emit(PitchError(e.toString()));
    }
  }

  Future<void> _onFetchStatus(FetchPitchRequestStatus event, Emitter<PitchState> emit) async {
    emit(PitchLoading());
    try {
      final request = await _repository.getPitchRequestForIdea(event.ideaId, event.investorId);
      emit(PitchRequestStatusLoaded(request));
    } catch (e) {
      emit(PitchError(e.toString()));
    }
  }

  Future<void> _onUpdateStatus(UpdatePitchStatus event, Emitter<PitchState> emit) async {
    try {
      await _repository.updatePitchRequestStatus(
        requestId: event.requestId,
        status: event.status,
        pitchDeckUrl: event.pitchDeckUrl,
      );
      // We don't necessarily emit a state here if the UI is updated via 
      // subsequent fetch or if it's an innovator action.
    } catch (e) {
      emit(PitchError(e.toString()));
    }
  }
}
