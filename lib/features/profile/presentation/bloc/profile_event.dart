import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class FetchProfileById extends ProfileEvent {
  final String userId;
  const FetchProfileById(this.userId);
  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final ProfileModel profile;
  const UpdateProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}

class UploadAvatar extends ProfileEvent {
  final dynamic imageFile; // File or XFile
  const UploadAvatar(this.imageFile);
  @override
  List<Object?> get props => [imageFile];
}

class LoadCollaboratorProfile extends ProfileEvent {
  final String profileId;
  const LoadCollaboratorProfile(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class SaveCollaboratorProfile extends ProfileEvent {
  final CollaboratorProfile profile;
  const SaveCollaboratorProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}
