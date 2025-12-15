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

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;
  const UpdateProfile(this.profile);
  @override
  List<Object> get props => [profile];
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
  const ProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
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
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getMyProfile();
      if (profile != null) {
        emit(ProfileLoaded(profile));
      } else {
        emit(const ProfileError("User not logged in"));
      }
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
}
