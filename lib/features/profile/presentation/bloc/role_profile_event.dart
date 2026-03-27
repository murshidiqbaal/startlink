// lib/features/profile/presentation/bloc/role_profile_event.dart
//
// Events for the non-generic RoleProfileBloc.

import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';

abstract class RoleProfileEvent extends Equatable {
  const RoleProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadRoleProfile extends RoleProfileEvent {
  final String role;

  const LoadRoleProfile({required this.role});

  @override
  List<Object?> get props => [role];
}

class UpdateRoleProfile extends RoleProfileEvent {
  final ProfileModel baseProfile;
  final RoleProfile roleProfile;

  const UpdateRoleProfile({
    required this.baseProfile,
    required this.roleProfile,
  });

  @override
  List<Object?> get props => [baseProfile, roleProfile];
}

class SubmitVerificationRequest extends RoleProfileEvent {
  final String profileId;
  final String role;

  const SubmitVerificationRequest({
    required this.profileId,
    required this.role,
  });

  @override
  List<Object?> get props => [profileId, role];
}

class UpdateRoleCompletion extends RoleProfileEvent {
  final int score;
  const UpdateRoleCompletion(this.score);
  @override
  List<Object?> get props => [score];
}
