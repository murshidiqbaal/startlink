import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/admin/domain/repositories/admin_repository.dart';
import 'package:startlink/features/idea/data/models/idea_model.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/profile/data/models/user_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRepositoryImpl implements AdminRepository {
  final SupabaseClient _supabase;

  AdminRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<UserProfile>> getAllUsers() async {
    // We used public.profiles (user_profiles view or table)
    final response = await _supabase
        .from(
          'profiles',
        ) // Assuming 'profiles' is the main table, or 'user_profiles'
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => UserProfileModel.fromJson(e)).toList();
  }

  @override
  Future<void> banUser(String userId) async {
    // Ideally calls an RPC or updates a status field
    // Assuming we have a 'status' or 'is_banned' column
    // If not, we'll try to update metadata via RPC or edge function
    // For now, let's assume valid column 'status'='banned'
    await _supabase
        .from('profiles')
        .update({'status': 'banned'})
        .eq('id', userId);
  }

  @override
  Future<void> unbanUser(String userId) async {
    await _supabase
        .from('profiles')
        .update({'status': 'active'})
        .eq('id', userId);
  }

  @override
  Future<List<Idea>> getAllIdeas() async {
    final response = await _supabase
        .from('ideas')
        .select()
        .order('created_at', ascending: false);
    return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
  }

  @override
  Future<void> deleteIdea(String ideaId) async {
    await _supabase.from('ideas').delete().eq('id', ideaId);
  }

  @override
  Future<void> flagIdea(String ideaId) async {
    await _supabase.from('ideas').update({'is_flagged': true}).eq('id', ideaId);
  }
}
