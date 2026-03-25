import 'package:flutter/foundation.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';

part 'collaboration_event.dart';
part 'collaboration_state.dart';

class CollaborationBloc extends Bloc<CollaborationEvent, CollaborationState> {
  final CollaborationRepository _repository;

  CollaborationBloc({required CollaborationRepository repository})
      : _repository = repository,
        super(CollaborationInitial()) {
    on<ApplyCollaboration>(_onApplyCollaboration);
    on<LoadIdeaApplications>(_onLoadIdeaApplications);
    on<AcceptCollaborationRequest>(_onAcceptCollaborationRequest);
    on<RejectCollaborationRequest>(_onRejectCollaborationRequest);
    on<FetchMyCollaborations>(_onFetchMyCollaborations);
    on<FetchReceivedCollaborations>(_onFetchReceivedCollaborations);
    on<UpdateCollaborationStatus>(_onUpdateCollaborationStatus);
  }

  Future<void> _onApplyCollaboration(
    ApplyCollaboration event,
    Emitter<CollaborationState> emit,
  ) async {
    debugPrint('DEBUG: CollaborationBloc received ApplyCollaboration event');
    emit(CollaborationLoading());
    try {
      await _repository.applyForIdea(
        ideaId: event.ideaId,
        innovatorId: event.innovatorId,
        roleApplied: event.roleApplied,
        message: event.message,
      );
      emit(const CollaborationApplied('Application submitted successfully!'));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onLoadIdeaApplications(
    LoadIdeaApplications event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      final applications = await _repository.getIdeaApplications(event.ideaId);
      emit(CollaborationLoaded(applications));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onAcceptCollaborationRequest(
    AcceptCollaborationRequest event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      await _repository.updateApplicationStatus(
        requestId: event.requestId,
        status: 'accepted',
      );
      emit(const CollaborationActionSuccess('Application accepted!'));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onRejectCollaborationRequest(
    RejectCollaborationRequest event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      await _repository.updateApplicationStatus(
        requestId: event.requestId,
        status: 'rejected',
      );
      emit(const CollaborationActionSuccess('Application rejected!'));
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
      final applications = await _repository.fetchMyCollaborations();
      emit(CollaborationLoaded(applications));
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
      final applications = await _repository.fetchReceivedCollaborations();
      emit(CollaborationLoaded(applications));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }

  Future<void> _onUpdateCollaborationStatus(
    UpdateCollaborationStatus event,
    Emitter<CollaborationState> emit,
  ) async {
    emit(CollaborationLoading());
    try {
      await _repository.updateApplicationStatus(
        requestId: event.collaborationId,
        status: event.status.toLowerCase(),
      );
      emit(const CollaborationActionSuccess('Status updated successfully'));
    } catch (e) {
      emit(CollaborationError(e.toString()));
    }
  }
}
