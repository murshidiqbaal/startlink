import 'package:startlink/features/pitch_health/domain/entities/pitch_score.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class PitchHealthRepository {
  Future<PitchScore> analyzePitch(String title, String description);
}

class PitchHealthRepositoryImpl implements PitchHealthRepository {
  final SupabaseClient _supabase;

  PitchHealthRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<PitchScore> analyzePitch(String title, String description) async {
    try {
      // lightweight analysis (could be local rule-based + AI)
      final response = await _supabase.functions.invoke(
        'analyze-pitch-health',
        body: {'title': title, 'description': description},
      );

      if (response.status != 200) {
        // Fallback or throw
        return PitchScore.empty();
      }

      final data = response.data;
      return PitchScore(
        overallScore: data['overall_score'] ?? 0,
        clarity: data['clarity'] ?? 0,
        marketFit: data['market_fit'] ?? 0,
        investorReadiness: data['investor_readiness'] ?? 0,
        storytelling: data['storytelling'] ?? 0,
        suggestions: List<String>.from(data['suggestions'] ?? []),
      );
    } catch (e) {
      // Fail silently for live analysis
      return PitchScore.empty();
    }
  }
}
