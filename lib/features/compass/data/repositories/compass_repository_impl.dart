import 'package:flutter/foundation.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/compass/data/models/compass_recommendation_model.dart';
import 'package:startlink/features/compass/domain/entities/compass_recommendation.dart';
import 'package:startlink/features/compass/domain/repositories/compass_repository.dart';
import 'package:startlink/features/compass/domain/utils/compass_rule_engine.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompassRepositoryImpl implements CompassRepository {
  final SupabaseClient _supabase;

  CompassRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<CompassRecommendation>> getRecommendations(
    String profileId,
  ) async {
    try {
      final response = await _supabase
          .from('user_compass_recommendations')
          .select()
          .eq('profile_id', profileId)
          .order('priority', ascending: false)
          .limit(3);

      return (response as List)
          .map((json) => CompassRecommendationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch compass recommendations: $e');
    }
  }

  @override
  Future<void> recalculateRecommendations(
    ProfileModel profile, {
    List<Idea>? ideas,
  }) async {
    try {
      final recs = CompassRuleEngine.evaluate(profile, ideas);

      // Clean existing
      await _supabase
          .from('user_compass_recommendations')
          .delete()
          .eq('profile_id', profile.id);

      if (recs.isNotEmpty) {
        final toInsert = recs.map((r) {
          final json = r.toJson();
          json.remove('id'); // Let DB gen id
          return json;
        }).toList();

        await _supabase.from('user_compass_recommendations').insert(toInsert);
      }
    } catch (e) {
      debugPrint('Failed to recalculate compass: $e');
    }
  }
}
