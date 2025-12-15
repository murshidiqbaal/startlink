import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
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
}
