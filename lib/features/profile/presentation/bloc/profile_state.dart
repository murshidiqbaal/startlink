import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final ProfileModel profile;
  final CollaboratorProfileModel? collaboratorProfile;
  final bool isAvatarUploading;

  const ProfileLoaded(
    this.profile, {
    this.collaboratorProfile,
    this.isAvatarUploading = false,
  });

  @override
  List<Object?> get props => [profile, collaboratorProfile, isAvatarUploading];
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
  @override
  List<Object?> get props => [message];
}
