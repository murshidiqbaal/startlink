import 'dart:io';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class ProfileRepository {
  // ── Base profile ────────────────────────────────────────────────────────

  Future<ProfileModel> fetchCurrentProfile();
  Future<ProfileModel> fetchProfileById(String profileId);
  Future<void> updateProfile(ProfileModel profile);
  Future<String> uploadAvatar(File file);

  // ── Unified role profile (non-generic) ──────────────────────────────────

  /// Fetch the role-specific profile row for [profileId] given a [role] string.
  /// Returns null when no row exists yet.
  Future<RoleProfile?> fetchRoleProfile(String profileId, String role);

  /// Persist a role-specific profile row. Dispatches to the correct table by
  /// runtime type — no generics, no unsafe casts.
  Future<void> saveRoleProfile(RoleProfile profile);

  // ── Role-specific (kept for backward compat & ProfileGateBloc) ──────────

  Future<InnovatorProfile?> fetchInnovatorProfile(String profileId);
  Future<void> upsertInnovatorProfile(InnovatorProfile profile);

  Future<InvestorProfile?> fetchInvestorProfile(String profileId);
  Future<void> upsertInvestorProfile(InvestorProfile model);

  Future<MentorProfile?> fetchMentorProfile(String profileId);
  Future<void> upsertMentorProfile(MentorProfile model);

  Future<CollaboratorProfile?> fetchCollaboratorProfile(String profileId);
  Future<void> upsertCollaboratorProfile(CollaboratorProfile model);

  // ── Verification & Badges ──────────────────────────────────────────────

  Future<UserVerification?> fetchUserVerification(String userId, String role);
  Future<List<UserBadge>> fetchUserBadges(String userId);
  Future<void> submitVerificationRequest(String userId, String role, String type);
  Future<void> createVerificationRequest(String profileId, String role);
}
