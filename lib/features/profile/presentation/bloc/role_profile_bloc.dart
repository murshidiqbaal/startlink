import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';

// ── Investor BLoC ────────────────────────────────────────────────────────────

abstract class InvestorProfileEvent {}

class LoadInvestorProfile extends InvestorProfileEvent {
  final String profileId;
  LoadInvestorProfile(this.profileId);
}

class SaveInvestorProfile extends InvestorProfileEvent {
  final InvestorProfile profile;
  SaveInvestorProfile(this.profile);
}

abstract class InvestorProfileState {}

class InvestorProfileInitial extends InvestorProfileState {}

class InvestorProfileLoading extends InvestorProfileState {}

class InvestorProfileLoaded extends InvestorProfileState {
  final InvestorProfile profile;
  InvestorProfileLoaded(this.profile);
}

class InvestorProfileSaving extends InvestorProfileState {
  final InvestorProfile profile;
  InvestorProfileSaving(this.profile);
}

class InvestorProfileSaved extends InvestorProfileState {
  final InvestorProfile profile;
  InvestorProfileSaved(this.profile);
}

class InvestorProfileError extends InvestorProfileState {
  final String message;
  InvestorProfileError(this.message);
}

class InvestorProfileBloc
    extends Bloc<InvestorProfileEvent, InvestorProfileState> {
  final ProfileRepository _repo;

  InvestorProfileBloc({required ProfileRepository repository})
    : _repo = repository,
      super(InvestorProfileInitial()) {
    on<LoadInvestorProfile>(_onLoad);
    on<SaveInvestorProfile>(_onSave);
  }

  Future<void> _onLoad(
    LoadInvestorProfile event,
    Emitter<InvestorProfileState> emit,
  ) async {
    emit(InvestorProfileLoading());
    try {
      final profile = await _repo.fetchInvestorProfile(event.profileId);
      emit(
        InvestorProfileLoaded(
          profile ?? InvestorProfileModel(profileId: event.profileId),
        ),
      );
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  Future<void> _onSave(
    SaveInvestorProfile event,
    Emitter<InvestorProfileState> emit,
  ) async {
    final prev = state;
    emit(InvestorProfileSaving(event.profile));
    try {
      await _repo.upsertInvestorProfile(event.profile);
      emit(InvestorProfileSaved(event.profile));
      emit(InvestorProfileLoaded(event.profile));
    } catch (e) {
      if (prev is InvestorProfileLoaded) emit(prev);
      emit(InvestorProfileError(e.toString()));
    }
  }
}

// ── Mentor BLoC ──────────────────────────────────────────────────────────────

abstract class MentorProfileEvent {}

class LoadMentorProfile extends MentorProfileEvent {
  final String profileId;
  LoadMentorProfile(this.profileId);
}

class SaveMentorProfile extends MentorProfileEvent {
  final MentorProfile profile;
  SaveMentorProfile(this.profile);
}

abstract class MentorProfileState {}

class MentorProfileInitial extends MentorProfileState {}

class MentorProfileLoading extends MentorProfileState {}

class MentorProfileLoaded extends MentorProfileState {
  final MentorProfile profile;
  MentorProfileLoaded(this.profile);
}

class MentorProfileSaving extends MentorProfileState {
  final MentorProfile profile;
  MentorProfileSaving(this.profile);
}

class MentorProfileSaved extends MentorProfileState {
  final MentorProfile profile;
  MentorProfileSaved(this.profile);
}

class MentorProfileError extends MentorProfileState {
  final String message;
  MentorProfileError(this.message);
}

class MentorProfileBloc extends Bloc<MentorProfileEvent, MentorProfileState> {
  final ProfileRepository _repo;

  MentorProfileBloc({required ProfileRepository repository})
    : _repo = repository,
      super(MentorProfileInitial()) {
    on<LoadMentorProfile>(_onLoad);
    on<SaveMentorProfile>(_onSave);
  }

  Future<void> _onLoad(
    LoadMentorProfile event,
    Emitter<MentorProfileState> emit,
  ) async {
    emit(MentorProfileLoading());
    try {
      final profile = await _repo.fetchMentorProfile(event.profileId);
      emit(
        MentorProfileLoaded(
          profile ?? MentorProfileModel(profileId: event.profileId),
        ),
      );
    } catch (e) {
      emit(MentorProfileError(e.toString()));
    }
  }

  Future<void> _onSave(
    SaveMentorProfile event,
    Emitter<MentorProfileState> emit,
  ) async {
    final prev = state;
    emit(MentorProfileSaving(event.profile));
    try {
      await _repo.upsertMentorProfile(event.profile);
      emit(MentorProfileSaved(event.profile));
      emit(MentorProfileLoaded(event.profile));
    } catch (e) {
      if (prev is MentorProfileLoaded) emit(prev);
      emit(MentorProfileError(e.toString()));
    }
  }
}

// ── Collaborator BLoC ────────────────────────────────────────────────────────

abstract class CollaboratorProfileEvent {}

class FetchCollaboratorProfile extends CollaboratorProfileEvent {
  final String profileId;
  FetchCollaboratorProfile(this.profileId);
}

class UpdateCollaboratorProfile extends CollaboratorProfileEvent {
  final CollaboratorProfile profile;
  UpdateCollaboratorProfile(this.profile);
}

abstract class CollaboratorProfileState {}

class CollaboratorProfileInitial extends CollaboratorProfileState {}

class CollaboratorProfileLoading extends CollaboratorProfileState {}

class CollaboratorProfileLoaded extends CollaboratorProfileState {
  final CollaboratorProfile profile;
  CollaboratorProfileLoaded(this.profile);
}

class CollaboratorProfileUpdating extends CollaboratorProfileState {
  final CollaboratorProfile profile;
  CollaboratorProfileUpdating(this.profile);
}

class CollaboratorProfileUpdated extends CollaboratorProfileState {
  final CollaboratorProfile profile;
  CollaboratorProfileUpdated(this.profile);
}

class CollaboratorProfileError extends CollaboratorProfileState {
  final String message;
  CollaboratorProfileError(this.message);
}

class CollaboratorProfileBloc
    extends Bloc<CollaboratorProfileEvent, CollaboratorProfileState> {
  final ProfileRepository _repo;

  CollaboratorProfileBloc({required ProfileRepository repository})
    : _repo = repository,
      super(CollaboratorProfileInitial()) {
    on<FetchCollaboratorProfile>(_onFetch);
    on<UpdateCollaboratorProfile>(_onUpdate);
  }

  Future<void> _onFetch(
    FetchCollaboratorProfile event,
    Emitter<CollaboratorProfileState> emit,
  ) async {
    emit(CollaboratorProfileLoading());
    try {
      final profile = await _repo.fetchCollaboratorProfile(event.profileId);
      emit(
        CollaboratorProfileLoaded(
          profile ?? CollaboratorProfileModel(profileId: event.profileId),
        ),
      );
    } catch (e) {
      emit(CollaboratorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateCollaboratorProfile event,
    Emitter<CollaboratorProfileState> emit,
  ) async {
    final prev = state;
    emit(CollaboratorProfileUpdating(event.profile));
    try {
      await _repo.upsertCollaboratorProfile(event.profile);
      emit(CollaboratorProfileUpdated(event.profile));
      emit(CollaboratorProfileLoaded(event.profile));
    } catch (e) {
      if (prev is CollaboratorProfileLoaded) emit(prev);
      emit(CollaboratorProfileError(e.toString()));
    }
  }
}
