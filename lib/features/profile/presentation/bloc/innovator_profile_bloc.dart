// lib/features/profile/presentation/bloc/innovator_profile_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/data/models/innovator_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────────

// ── Events ────────────────────────────────────────────────────────────────────

abstract class InnovatorProfileEvent extends Equatable {
  const InnovatorProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadInnovatorProfile extends InnovatorProfileEvent {
  final String profileId;
  const LoadInnovatorProfile(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class SaveInnovatorProfile extends InnovatorProfileEvent {
  final InnovatorProfile profile;
  const SaveInnovatorProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}

// ── State ─────────────────────────────────────────────────────────────────────

enum InnovatorProfileStatus {
  initial,
  loading,
  loaded,
  saving,
  success,
  failure,
}

class InnovatorProfileState extends Equatable {
  final InnovatorProfileStatus status;
  final InnovatorProfile? profile;
  final String? errorMessage;
  final bool avatarUploading;

  const InnovatorProfileState({
    this.status = InnovatorProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.avatarUploading = false,
  });

  @override
  List<Object?> get props => [status, profile, errorMessage, avatarUploading];

  InnovatorProfileState copyWith({
    InnovatorProfileStatus? status,
    InnovatorProfile? profile,
    String? errorMessage,
    bool? avatarUploading,
  }) => InnovatorProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    errorMessage: errorMessage ?? this.errorMessage,
    avatarUploading: avatarUploading ?? this.avatarUploading,
  );
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class InnovatorProfileBloc
    extends Bloc<InnovatorProfileEvent, InnovatorProfileState> {
  final ProfileRepository _repo;

  InnovatorProfileBloc({required ProfileRepository repository})
    : _repo = repository,
      super(const InnovatorProfileState()) {
    on<LoadInnovatorProfile>(_onLoad);
    on<SaveInnovatorProfile>(_onSave);
  }

  Future<void> _onLoad(
    LoadInnovatorProfile event,
    Emitter<InnovatorProfileState> emit,
  ) async {
    emit(state.copyWith(status: InnovatorProfileStatus.loading));
    try {
      final profile = await _repo.fetchInnovatorProfile(event.profileId);

      // If no row exists yet, return an empty model so the edit screen can
      // still prefill from the base profile
      emit(
        state.copyWith(
          status: InnovatorProfileStatus.loaded,
          profile: profile ?? InnovatorProfileModel(profileId: event.profileId),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InnovatorProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSave(
    SaveInnovatorProfile event,
    Emitter<InnovatorProfileState> emit,
  ) async {
    emit(state.copyWith(status: InnovatorProfileStatus.saving));
    try {
      await _repo.upsertInnovatorProfile(event.profile);

      emit(
        state.copyWith(
          status: InnovatorProfileStatus.success,
          profile: event.profile,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InnovatorProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
