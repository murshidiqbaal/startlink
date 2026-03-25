import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';

// Events
abstract class MentorProfileEvent extends Equatable {
  const MentorProfileEvent();
  @override
  List<Object> get props => [];
}

class LoadMentorProfile extends MentorProfileEvent {
  final String profileId;
  const LoadMentorProfile(this.profileId);
  @override
  List<Object> get props => [profileId];
}

class SaveMentorProfile extends MentorProfileEvent {
  final MentorProfile profile;
  const SaveMentorProfile(this.profile);
  @override
  List<Object> get props => [profile];
}

// States
abstract class MentorProfileState extends Equatable {
  const MentorProfileState();
  @override
  List<Object> get props => [];
}

class MentorProfileInitial extends MentorProfileState {}

class MentorProfileLoading extends MentorProfileState {}

class MentorProfileLoaded extends MentorProfileState {
  final MentorProfile profile;
  const MentorProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
}

class MentorProfileSaving extends MentorProfileState {
  final MentorProfile profile;
  const MentorProfileSaving(this.profile);
  @override
  List<Object> get props => [profile];
}

class MentorProfileSaved extends MentorProfileState {
  final MentorProfile profile;
  const MentorProfileSaved(this.profile);
  @override
  List<Object> get props => [profile];
}

class MentorProfileError extends MentorProfileState {
  final String message;
  const MentorProfileError(this.message);
  @override
  List<Object> get props => [message];
}

class MentorProfileBloc extends Bloc<MentorProfileEvent, MentorProfileState> {
  final ProfileRepository _repository;

  MentorProfileBloc({required ProfileRepository repository})
    : _repository = repository,
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
      final profile = await _repository.fetchMentorProfile(event.profileId);
      if (profile != null) {
        emit(MentorProfileLoaded(profile));
      } else {
        emit(
          MentorProfileLoaded(
            MentorProfileModel(profileId: event.profileId) as MentorProfile,
          ),
        );
      }
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
      await _repository.upsertMentorProfile(event.profile);
      emit(MentorProfileSaved(event.profile));
      emit(MentorProfileLoaded(event.profile));
    } catch (e) {
      if (prev is MentorProfileLoaded) emit(prev);
      emit(MentorProfileError(e.toString()));
    }
  }
}
