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

/// Load the base profile + role-specific profile for [profileId] with [role].
class LoadRoleProfile extends RoleProfileEvent {
  final String profileId;

  /// Lower-case role string: 'innovator' | 'investor' | 'mentor' | 'collaborator'
  final String role;

  const LoadRoleProfile({required this.profileId, required this.role});

  @override
  List<Object?> get props => [profileId, role];
}

/// Persist changes to both the base profile row and the role-specific table.
class SaveRoleProfile extends RoleProfileEvent {
  final ProfileModel baseProfile;
  final RoleProfile roleProfile;

  const SaveRoleProfile({
    required this.baseProfile,
    required this.roleProfile,
  });

  @override
  List<Object?> get props => [baseProfile, roleProfile];
}

/// Fired from edit-form controllers to recalculate the live completion bar.
class UpdateRoleCompletion extends RoleProfileEvent {
  final int score;
  const UpdateRoleCompletion(this.score);
  @override
  List<Object?> get props => [score];
}
