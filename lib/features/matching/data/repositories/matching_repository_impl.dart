import 'package:flutter/foundation.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/matching/data/models/idea_match_model.dart';
import 'package:startlink/features/matching/domain/entities/idea_match.dart';
import 'package:startlink/features/matching/domain/repositories/matching_repository.dart';
import 'package:startlink/features/matching/domain/utils/match_score_calculator.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MatchingRepositoryImpl implements MatchingRepository {
  final SupabaseClient _supabase;

  MatchingRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<List<IdeaMatch>> getMatchesForIdea(String ideaId) async {
    try {
      // Fetch matches joined with profiles
      final response = await _supabase
          .from('idea_matches')
          .select('*, profiles:matched_profile_id(*)') // Join profile data
          .eq('idea_id', ideaId)
          .order('match_score', ascending: false)
          .limit(5);

      return (response as List)
          .map((json) => IdeaMatchModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch matches: $e');
    }
  }

  @override
  Future<void> generateMatchesForIdea(Idea idea) async {
    try {
      // 1. Fetch Candidates (Simplification: fetch top 50 active users)
      // In prod, use RPC or specific filters
      // Need profiles + their aura/trust (if joined or separate)
      // Assuming aura and trust are in separate tables, we might need a complex query.
      // For MVP AI-light, we'll just fetch profiles and "mock" trust/aura or fetch if possible.
      // Supabase join syntax:
      final response = await _supabase
          .from('profiles')
          .select('*, user_trust_scores(score), user_aura(points)')
          .neq('id', idea.ownerId) // Don't match self
          .limit(50); // Pool size

      final List<Map<String, dynamic>> matchesToInsert = [];

      for (var row in response as List) {
        final profile = ProfileModel.fromJson(row);

        // Extract Trust & Aura safely
        // Note: relation names depend on foreign keys. standardized typically.
        int trust = 0;
        if (row['user_trust_scores'] != null &&
            (row['user_trust_scores'] as List).isNotEmpty) {
          trust = (row['user_trust_scores'][0]['score'] ?? 0);
        }

        int aura = 0;
        if (row['user_aura'] != null && (row['user_aura'] as List).isNotEmpty) {
          aura = (row['user_aura'][0]['points'] ?? 0);
        }

        // Calculate Score
        final result = MatchScoreCalculator.calculate(
          idea,
          profile,
          trust,
          aura,
        );
        final int score = result['score'];
        final Map<String, dynamic> reason = result['reason'];

        // Threshold
        if (score > 40) {
          // Only save decent matches
          final role = profile.role ?? 'Collaborator';

          matchesToInsert.add({
            'idea_id': idea.id,
            'matched_profile_id': profile.id,
            'role': role,
            'match_score': score,
            'match_reason': reason,
          });
        }
      }

      if (matchesToInsert.isNotEmpty) {
        // Upsert matches
        await _supabase
            .from('idea_matches')
            .upsert(matchesToInsert, onConflict: 'idea_id, matched_profile_id');
      }
    } catch (e) {
      // Log error but don't block flow
      debugPrint('Matching generation failed: $e');
    }
  }
}
