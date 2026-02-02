import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/profile/data/models/innovator_profile_model.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/data/models/user_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/user_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<ProfileModel?> getMyProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      // If profile doesn't exist, return empty profile if user is logged in
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        return ProfileModel(id: userId);
      }
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    await _supabase
        .from('profiles')
        .upsert(
          profile.toJson()..['id'] = userId,
        ); // Upsert to create if missing
  }

  @override
  Future<String?> uploadAvatar(dynamic imageFile) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName = '$userId/${DateTime.now().toIso8601String()}.$fileExt';
      final filePath = fileName;

      await _supabase.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }

  @override
  Future<ProfileModel?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return UserProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<InnovatorProfile?> getInnovatorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('innovator_profiles')
          .select()
          .eq('profile_id', profileId)
          .single();
      return InnovatorProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<MentorProfile?> getMentorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('mentor_profiles')
          .select()
          .eq('profile_id', profileId)
          .single();
      return MentorProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<InvestorProfile?> getInvestorProfile(String profileId) async {
    try {
      final response = await _supabase
          .from('investor_profiles')
          .select()
          .eq('profile_id', profileId)
          .single();
      return InvestorProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateInnovatorProfile(InnovatorProfile profile) async {
    final model = profile is InnovatorProfileModel
        ? profile
        : InnovatorProfileModel.fromEntity(profile);
    await _supabase.from('innovator_profiles').upsert(model.toJson());
  }

  @override
  Future<void> updateMentorProfile(MentorProfile profile) async {
    final model = profile is MentorProfileModel
        ? profile
        : MentorProfileModel.fromEntity(profile);
    await _supabase.from('mentor_profiles').upsert(model.toJson());
  }

  @override
  Future<void> updateInvestorProfile(InvestorProfile profile) async {
    final model = profile is InvestorProfileModel
        ? profile
        : InvestorProfileModel.fromEntity(profile);
    await _supabase.from('investor_profiles').upsert(model.toJson());
  }
}
