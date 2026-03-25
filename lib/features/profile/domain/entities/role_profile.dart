// lib/features/profile/domain/entities/role_profile.dart
//
// Base entity for ALL role-specific profiles.
// Every concrete profile (Innovator, Investor, Mentor, Collaborator) extends this.
// The unified ProfileBloc stores a `RoleProfile?` — the UI uses `is` checks
// to access role-specific fields without any unsafe generic casting.

import 'package:equatable/equatable.dart';

abstract class RoleProfile extends Equatable {
  /// The profile ID (FK → profiles.id in Supabase)
  final String profileId;

  /// Lower-case role string: 'innovator' | 'investor' | 'mentor' | 'collaborator'
  final String role;

  /// 0–100 completion score calculated by ProfileCompletionService
  final int profileCompletion;

  /// Optional timestamps persisted by Supabase
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleProfile({
    required this.profileId,
    required this.role,
    this.profileCompletion = 0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [profileId, role, profileCompletion, createdAt, updatedAt];
}
