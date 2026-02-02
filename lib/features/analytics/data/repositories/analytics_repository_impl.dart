import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final SupabaseClient _supabase;

  AnalyticsRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<void> logAction({
    required String investorId,
    required String action,
    String? ideaId,
    String? domain,
    String? stage,
    int? trustScore,
  }) async {
    await _supabase.from('investor_analytics').insert({
      'investor_id': investorId,
      'action': action,
      'idea_id': ideaId,
      'domain_viewed': domain,
      'stage_viewed': stage,
      'trust_score_viewed': trustScore,
    });
  }

  @override
  Future<Map<String, dynamic>> getInvestorInsights(String investorId) async {
    // 1. Top Domains
    final domainStats = await _supabase
        .from('investor_analytics')
        .select('domain_viewed')
        .eq('investor_id', investorId)
        .eq('action', 'view')
        .not('domain_viewed', 'is', null);

    // Simple aggregation client-side for MVP (PostgREST grouping is tricky without RPC)
    final Map<String, int> domains = {};
    for (var r in domainStats) {
      final d = r['domain_viewed'] as String;
      domains[d] = (domains[d] ?? 0) + 1;
    }
    final topDomains = domains.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 2. Stage Preference (similar logic)
    final stageStats = await _supabase
        .from('investor_analytics')
        .select('stage_viewed')
        .eq('investor_id', investorId)
        .eq('action', 'view')
        .not('stage_viewed', 'is', null);

    final Map<String, int> stages = {};
    for (var r in stageStats) {
      final s = r['stage_viewed'] as String;
      stages[s] = (stages[s] ?? 0) + 1;
    }

    return {
      'top_domains': topDomains
          .take(3)
          .map((e) => {'domain': e.key, 'count': e.value})
          .toList(),
      'stage_preference': stages,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getConfidenceHistory(String ideaId) async {
    // Return last 4 weeks of confidence
    final response = await _supabase
        .from('idea_confidence_history')
        .select('confidence_score, calculated_at')
        .eq('idea_id', ideaId)
        .order('calculated_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }
}
