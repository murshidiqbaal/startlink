import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';

part 'collaboration_event.dart';
part 'collaboration_state.dart';

class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  final CollaborationRepository _repository;

  CollaborationBloc({required CollaborationRepository repository})
    : _repository = repository,
      super(CollaborationInitial()) {
    on<ApplyCollaboration>(_onApplyCollaboration);
    on<FetchMyCollaborations>(_onFetchMyCollaborations);
    on<FetchCollaborationsForIdea>(_onFetchCollaborationsForIdea);
    on<FetchReceivedCollaborations>(_onFetchReceivedCollaborations);
    on<UpdateCollaborationStatus>(_onUpdateCollaborationStatus);
  }

  Future<void> _onApplyCollaboration(
    ApplyCollaboration event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      await _repository.applyForCollaboration(
        ideaId: event.ideaId,
        innovatorId: event.innovatorId,
        roleApplied: event.roleApplied,
        message: event.message,
      );
      emit(
        const CollaborationActionSuccess('Application submitted successfully!'),
      );
      // No default refresh here as context varies
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onFetchMyCollaborations(
    FetchMyCollaborations event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      final collaborations = await _repository.fetchMyCollaborations();
      emit(CollaborationLoaded(collaborations));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onFetchReceivedCollaborations(
    FetchReceivedCollaborations event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      final collaborations = await _repository.fetchReceivedCollaborations();
      emit(CollaborationLoaded(collaborations));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onFetchCollaborationsForIdea(
    FetchCollaborationsForIdea event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      final collaborations = await _repository.fetchCollaborationsForIdea(
        event.ideaId,
      );
      emit(CollaborationLoaded(collaborations));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onUpdateCollaborationStatus(
    UpdateCollaborationStatus event,
    Emitter<CollaborationState> emit,
  ) async {
    // Preserve current list if possible or just show loading overlay
    // For simplicity, emit loading then success
    emit(CollaborationLoading());
    try {
      await _repository.updateCollaborationStatus(
        collaborationId: event.collaborationId,
        status: event.status,
      );
      emit(const CollaborationActionSuccess('Status updated successfully'));
      // We might want to refresh the list depending on context (Idea or My Lists)
      // Since this action is usually done by Innovator viewing Idea applicants, we can't easily guess which list to refresh without more context
      // But typically the UI will listen to success and then request a refresh.
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }
}
