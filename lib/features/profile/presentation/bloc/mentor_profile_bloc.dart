import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/domain/repositories/mentor_repository.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_state.dart';

class MentorProfileBloc extends Bloc<MentorProfileEvent, MentorProfileState> {
  final MentorRepository _repository;
  final ProfileRepository _profileRepository;

  MentorProfileBloc({
    required MentorRepository repository,
    required ProfileRepository profileRepository,
  })  : _repository = repository,
        _profileRepository = profileRepository,
        super(MentorProfileInitial()) {
    on<LoadMentorProfile>(_onLoadProfile);
    on<UpdateMentorProfile>(_onUpdateProfile);
    on<SubmitMentorProfile>(_onUpdateProfile); // Reuse update logic
    on<SubmitVerification>(_onSubmitVerification);
    on<UpdateConsolidatedProfile>(_onUpdateConsolidatedProfile);
  }

  Future<void> _onLoadProfile(
    LoadMentorProfile event,
    Emitter<MentorProfileState> emit,
  ) async {
    emit(MentorProfileLoading());
    try {
      final baseProfile = await _profileRepository.fetchProfileById(event.userId);
      final profile = await _repository.getProfile(event.userId);
      final verification = await _repository.getVerificationStatus(event.userId);

      if (profile != null) {
        emit(MentorProfileLoaded(
          baseProfile: baseProfile,
          profile: profile,
          verification: verification,
        ));
      } else {
        emit(const MentorProfileError('Mentor profile not found. Please complete your setup.'));
      }
    } catch (e) {
      emit(MentorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    MentorProfileEvent event,
    Emitter<MentorProfileState> emit,
  ) async {
    final profile = (event is UpdateMentorProfile)
        ? event.profile
        : (event as SubmitMentorProfile).profile;

    emit(MentorProfileSaving());
    try {
      await _repository.updateProfile(profile);
      emit(MentorProfileSaved());
      // Reload profile after save
      add(LoadMentorProfile(profile.profileId));
    } catch (e) {
      emit(MentorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateConsolidatedProfile(
    UpdateConsolidatedProfile event,
    Emitter<MentorProfileState> emit,
  ) async {
    emit(MentorProfileSaving());
    try {
      // 1. Update base profile
      await _profileRepository.updateProfile(event.baseProfile);
      // 2. Update mentor profile
      await _repository.updateProfile(event.mentorProfile);

      emit(MentorProfileSaved());
      // Reload profile after save
      add(LoadMentorProfile(event.baseProfile.id));
    } catch (e) {
      emit(MentorProfileError(e.toString()));
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<MentorProfileState> emit,
  ) async {
    emit(MentorProfileSaving());
    try {
      await _repository.submitVerification(event.userId);
      emit(MentorProfileSaved());
      // Reload status
      add(LoadMentorProfile(event.userId));
    } catch (e) {
      emit(MentorProfileError(e.toString()));
    }
  }
}
