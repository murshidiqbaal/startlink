import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/idea/data/models/idea_model.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdeaRepositoryImpl implements IdeaRepository {
  final SupabaseClient _supabase;

  IdeaRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<Idea>> fetchMyIdeas() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('ideas')
          .select()
          .eq('owner_id', userId)
          .order('created_at', ascending: false);

      return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch ideas: $e');
    }
  }
}
