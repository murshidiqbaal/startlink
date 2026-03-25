import 'package:flutter/foundation.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/ai_insights/domain/entities/ai_insight.dart';
import 'package:startlink/features/ai_insights/domain/repositories/ai_insight_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIInsightRepositoryImpl implements AIInsightRepository {
  final SupabaseClient _supabase;

  AIInsightRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<AIInsight> getInsight(String ideaId, String investorId) async {
    try {
      // 1. Fetch Idea AI Data
      final ideaData = await _supabase
          .from('ideas')
          .select(
            'ai_investment_summary, ai_strengths, ai_risks, ai_market_potential, ai_execution_risk, target_market, current_stage, tags',
          )
          .eq('id', ideaId)
          .maybeSingle();

      // 2. Fetch Investor Profile for Fit Calculation
      final investorData = await _supabase
          .from('profiles')
          .select()
          .eq('id', investorId)
          .maybeSingle();

      // 3. Calculate Personal Fit (Client-side logic for MVP as requested to be abstracted)
      // In a real app, this might be an Edge Function call if the logic is complex/proprietary.
      final fit = _calculateInvestorFit(ideaData!, investorData!);

      return AIInsight(
        ideaId: ideaId,
        summary: ideaData['ai_investment_summary'],
        strengths: List<String>.from(ideaData['ai_strengths'] ?? []),
        risks: List<String>.from(ideaData['ai_risks'] ?? []),
        marketPotential: ideaData['ai_market_potential'] ?? 'Unknown',
        executionRisk: ideaData['ai_execution_risk'] ?? 'Unknown',
        personalFitScore: fit.score,
        fitReasons: fit.reasons,
      );
    } catch (e) {
      // Graceful degradation: return empty insight or rethrow if strict
      debugPrint('Error fetching AI insights: $e');
      return AIInsight(ideaId: ideaId);
    }
  }

  @override
  Future<void> analyzeIdea(String ideaId) async {
    try {
      await _supabase.functions.invoke(
        'analyze_idea',
        body: {'ideaId': ideaId},
      );
    } catch (e) {
      throw Exception('Failed to trigger AI analysis: $e');
    }
  }

  ({int score, List<String> reasons}) _calculateInvestorFit(
    Map<String, dynamic> idea,
    Map<String, dynamic> investor,
  ) {
    int score = 60; // Base score
    List<String> reasons = [];

    // Check Industry/Domain match (using Tags vs Interest metadata if available)
    // Assuming investor profile has 'metadata' -> 'interests' or similar custom fields from previous steps?
    // The prompt implies we have "Investment focus" in the investor profile.
    // Let's assume 'skills' or 'about' contains keywords for this Mock Logic,
    // or strictly metadata if we had defined it in a previous step.
    // For MVP transparency:

    final ideaTags = List<String>.from(idea['tags'] ?? []);
    final investorAbout = (investor['about'] ?? '').toString().toLowerCase();

    for (final tag in ideaTags) {
      if (investorAbout.contains(tag.toLowerCase())) {
        score += 10;
        reasons.add('Matches your interest in $tag');
      }
    }

    // Check Stage Fit
    final ideaStage = idea['current_stage'];
    // Assuming investor has preferred stage in metadata or about
    if (investorAbout.contains(ideaStage.toString().toLowerCase())) {
      score += 15;
      reasons.add('Fits your preference for $ideaStage stage');
    }

    return (score: score.clamp(0, 100), reasons: reasons);
  }
}
