import 'dart:io';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class ProfileRepository {
  // ── Base profile ────────────────────────────────────────────────────────

  /// Fetch the profile row for the currently authenticated user.
  Future<ProfileModel> fetchCurrentProfile();

  /// Fetch any profile by its profiles.id (PK).
  Future<ProfileModel> fetchProfileById(String profileId);

  /// Persist changes to the profiles table.
  Future<void> updateProfile(ProfileModel profile);

  /// Upload an avatar file to Supabase Storage.
  Future<String> uploadAvatar(File file);

  // ── Role-specific ────────────────────────────────────────────────────────

  Future<InnovatorProfile?> fetchInnovatorProfile(String profileId);
  Future<void> upsertInnovatorProfile(InnovatorProfile profile);

  Future<InvestorProfile?> fetchInvestorProfile(String profileId);
  Future<void> upsertInvestorProfile(InvestorProfile model);

  Future<MentorProfile?> fetchMentorProfile(String profileId);
  Future<void> upsertMentorProfile(MentorProfile model);

  Future<CollaboratorProfile?> fetchCollaboratorProfile(String profileId);
  Future<void> upsertCollaboratorProfile(CollaboratorProfile model);

  // ── Verification & Badges ──────────────────────────────────────────────────

  Future<UserVerification?> fetchUserVerification(String userId, String role);
  Future<List<UserBadge>> fetchUserBadges(String userId);
  Future<void> submitVerificationRequest(
    String userId,
    String role,
    String type,
  );
  Future<void> createVerificationRequest(String profileId, String role);
}


