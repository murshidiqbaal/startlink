import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/domain/utils/profile_completion_calculator.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_completion_service.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_state.dart';

export 'package:startlink/features/profile/presentation/bloc/profile_event.dart';
export 'package:startlink/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<FetchProfileById>(_onFetchProfileById);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
    on<LoadCollaboratorProfile>(_onLoadCollaboratorProfile);
    on<SaveCollaboratorProfile>(_onSaveCollaboratorProfile);
  }

  Future<void> _onLoadCollaboratorProfile(
    LoadCollaboratorProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(currentState.profile, collaboratorProfile: currentState.collaboratorProfile, isAvatarUploading: currentState.isAvatarUploading));
      try {
        final collabProfile = await _profileRepository.fetchCollaboratorProfile(event.profileId);
        emit(ProfileLoaded(currentState.profile, collaboratorProfile: collabProfile as CollaboratorProfileModel?));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    } else {
      emit(ProfileLoading());
      try {
        final profile = await _profileRepository.fetchProfileById(event.profileId);
        final collabProfile = await _profileRepository.fetchCollaboratorProfile(event.profileId);
        emit(ProfileLoaded(profile, collaboratorProfile: collabProfile as CollaboratorProfileModel?));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onSaveCollaboratorProfile(
    SaveCollaboratorProfile event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(currentState.profile, collaboratorProfile: currentState.collaboratorProfile, isAvatarUploading: true));
      try {
        // Calculate completion
        final updatedCollab = (event.profile as CollaboratorProfileModel).copyWith(
          profileCompletion: ProfileCompletionService.calculateCollaborator(event.profile),
        );
        await _profileRepository.upsertCollaboratorProfile(updatedCollab);
        emit(ProfileLoaded(currentState.profile, collaboratorProfile: updatedCollab, isAvatarUploading: false));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    }
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.fetchCurrentProfile();
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onFetchProfileById(
    FetchProfileById event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.fetchProfileById(event.userId);
      emit(ProfileLoaded(profile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final completionScore = ProfileCompletionCalculator.calculate(
        event.profile,
      );
      final updatedProfile = event.profile.copyWith(
        profileCompletion: completionScore,
      );

      await _profileRepository.updateProfile(updatedProfile);
      emit(ProfileLoaded(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUploadAvatar(
    UploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(currentState.profile, isAvatarUploading: true));
      try {
        final imageUrl = await _profileRepository.uploadAvatar(event.imageFile);
        if (imageUrl.isNotEmpty) {
          final updatedProfile = currentState.profile.copyWith(
            avatarUrl: imageUrl,
          );
          // Calculate new completion score as avatar might be the missing piece
          final completionScore = ProfileCompletionCalculator.calculate(
            updatedProfile,
          );
          final finalProfile = updatedProfile.copyWith(
            profileCompletion: completionScore,
          );

          await _profileRepository.updateProfile(finalProfile);
          emit(ProfileLoaded(finalProfile, isAvatarUploading: false));
        } else {
          emit(ProfileLoaded(currentState.profile, isAvatarUploading: false));
        }
      } catch (e) {
        // We stay in ProfileLoaded but set isAvatarUploading to false
        // and optionally emit an error if the UI needs it.
        // For now, let's keep the profile data and just stop the "loading" state.
        emit(ProfileLoaded(currentState.profile, isAvatarUploading: false));
        // You might want to also emit a side-effect for the error.
      }
    }
  }
}
