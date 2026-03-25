import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';
import 'package:startlink/features/profile/data/models/innovator_profile_model.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/verification/data/models/verification_models.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<ProfileModel> fetchCurrentProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) {
      // Return a default profile model if not found
      return ProfileModel(id: userId, userId: userId);
    }
    return ProfileModel.fromJson(response);
  }

  @override
  Future<ProfileModel> fetchProfileById(String profileId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', profileId)
        .maybeSingle();
    if (response == null) {
       throw Exception('Profile not found');
    }
    return ProfileModel.fromJson(response);
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    await _supabase.from('profiles').upsert(profile.toJson()..['id'] = userId);
  }

  @override
  Future<String> uploadAvatar(File file) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final fileExt = file.path.split('.').last;
    final fileName = '$userId/${DateTime.now().toIso8601String()}.$fileExt';

    await _supabase.storage.from('avatars').upload(fileName, file);
    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }

  // ── Role-specific ────────────────────────────────────────────────────────

  @override
  Future<InnovatorProfileModel?> fetchInnovatorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('innovator_profiles')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();
      if (response == null) return null;
      return InnovatorProfileModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertInnovatorProfile(InnovatorProfile profile) async {
    final model = InnovatorProfileModel.fromEntity(profile);
    await _supabase.from('innovator_profiles').upsert(model.toUpsertJson());
  }

  @override
  Future<InvestorProfileModel?> fetchInvestorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('investor_profiles')
          .select('*, profiles(about)')
          .eq('profile_id', profileId)
          .maybeSingle();

      if (response == null) return null;

      final json = Map<String, dynamic>.from(response);
      if (json['profiles'] != null) {
        json['bio'] = json['profiles']['about'];
      }

      return InvestorProfileModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertInvestorProfile(InvestorProfile profile) async {
    final model = InvestorProfileModel.fromEntity(profile);
    await _supabase.from('investor_profiles').upsert(model.toUpsertJson());

    // Sync bio to the profiles table
    if (profile.bio != null) {
      await _supabase
          .from('profiles')
          .update({'about': profile.bio})
          .eq('id', profile.profileId);
    }

    // Automatic Verification Trigger
    if (profile.profileCompletion >= 80) {
      await createVerificationRequest(profile.profileId, 'investor');
    }
  }

  @override
  Future<MentorProfileModel?> fetchMentorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('mentor_profiles')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();
      if (response == null) return null;
      return MentorProfileModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertMentorProfile(MentorProfile profile) async {
    final model = MentorProfileModel.fromEntity(profile);
    await _supabase.from('mentor_profiles').upsert(model.toUpsertJson());

    // Automatic Verification Trigger
    if (profile.profileCompletion >= 80) {
      await createVerificationRequest(profile.profileId, 'mentor');
    }
  }

  @override
  Future<CollaboratorProfileModel?> fetchCollaboratorProfile(
    String profileId,
  ) async {
    try {
      final response = await _supabase
          .from('collaborator_profiles')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();
      if (response == null) return null;
      return CollaboratorProfileModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertCollaboratorProfile(CollaboratorProfile profile) async {
    final model = CollaboratorProfileModel.fromEntity(profile);
    await _supabase.from('collaborator_profiles').upsert(model.toUpsertJson());
  }

  // ── Verification & Badges ──────────────────────────────────────────────────

  @override
  Future<UserVerification?> fetchUserVerification(
    String userId,
    String role,
  ) async {
    final response = await _supabase
        .from('user_verifications')
        .select()
        .eq('profile_id', userId)
        .eq('role', role)
        .maybeSingle();

    if (response == null) return null;
    return UserVerificationModel.fromJson(response);
  }

  @override
  Future<List<UserBadge>> fetchUserBadges(String userId) async {
    final response = await _supabase
        .from('user_badges')
        .select()
        .eq('profile_id', userId);

    return (response as List).map((e) => UserBadgeModel.fromJson(e)).toList();
  }

  @override
  Future<void> createVerificationRequest(String profileId, String role) async {
    await submitVerificationRequest(profileId, role, 'profile_verification');
  }

  @override
  Future<void> submitVerificationRequest(
    String userId,
    String role,
    String type,
  ) async {
    try {
      debugPrint('Repo: Checking existing request for $userId ($role)');
      // Check if a request already exists to prevent duplicates
      final existing = await _supabase
          .from('user_verifications')
          .select()
          .eq('profile_id', userId)
          .eq('role', role)
          .maybeSingle();

      if (existing != null) {
        debugPrint('Repo: Verification request already exists');
        return; // Don't throw for auto-trigger
      }

      debugPrint('Repo: Inserting into user_verifications...');
      await _supabase.from('user_verifications').insert({
        'profile_id': userId,
        'role': role,
        'verification_type': type,
        'status': 'Pending',
      });
      debugPrint('Repo: Insert successful');
    } catch (e) {
      debugPrint('Repo: Error in submitVerificationRequest: $e');
      rethrow;
    }
  }
}
