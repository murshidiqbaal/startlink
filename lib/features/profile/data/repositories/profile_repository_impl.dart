import 'dart:io';

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
        .single();
    return ProfileModel.fromJson(response);
  }

  @override
  Future<ProfileModel> fetchProfileById(String profileId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', profileId)
        .single();
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
          .single();
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
          .select()
          .eq('profile_id', profileId)
          .single();
      return InvestorProfileModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertInvestorProfile(InvestorProfile profile) async {
    final model = InvestorProfileModel.fromEntity(profile);
    await _supabase.from('investor_profiles').upsert(model.toUpsertJson());
  }

  @override
  Future<MentorProfileModel?> fetchMentorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('mentor_profiles')
          .select()
          .eq('profile_id', profileId)
          .single();
      return MentorProfileModel.fromJson(response);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertMentorProfile(MentorProfile profile) async {
    final model = MentorProfileModel.fromEntity(profile);
    await _supabase.from('mentor_profiles').upsert(model.toUpsertJson());
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
          .single();
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
}
