// lib/features/profile/presentation/widgets/profile_edit_framework/profile_edit_event.dart

import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';

abstract class ProfileEditEvent extends Equatable {
  const ProfileEditEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEditEvent {
  final String profileId;
  const LoadProfile(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class SaveProfile<T> extends ProfileEditEvent {
  final ProfileModel baseProfile;
  final T roleProfile;
  const SaveProfile({required this.baseProfile, required this.roleProfile});
  @override
  List<Object?> get props => [baseProfile, roleProfile];
}

class UpdateCompletion extends ProfileEditEvent {
  final int score;
  const UpdateCompletion(this.score);
  @override
  List<Object?> get props => [score];
}
