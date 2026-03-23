import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/domain/utils/profile_completion_calculator.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object> get props => [];
}

class FetchProfile extends ProfileEvent {}

class FetchProfileById extends ProfileEvent {
  final String userId;
  const FetchProfileById(this.userId);
  @override
  List<Object> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;
  const UpdateProfile(this.profile);
  @override
  List<Object> get props => [profile];
}

class UploadAvatar extends ProfileEvent {
  final dynamic imageFile; // File or XFile
  const UploadAvatar(this.imageFile);
  @override
  List<Object> get props => [imageFile];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final bool isAvatarUploading;

  const ProfileLoaded(this.profile, {this.isAvatarUploading = false});

  @override
  List<Object> get props => [profile, isAvatarUploading];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object> get props => [message];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileInitial()) {
    on<FetchProfile>(_onFetchProfile);
    on<FetchProfileById>(_onFetchProfileById);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadAvatar>(_onUploadAvatar);
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
        if (imageUrl != null) {
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
