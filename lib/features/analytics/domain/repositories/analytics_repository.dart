abstract class AnalyticsRepository {
  Future<void> logAction({
    required String investorId,
    required String action,
    String? ideaId,
    String? domain,
    String? stage,
    int? trustScore,
  });

  Future<Map<String, dynamic>> getInvestorInsights(String investorId);
  Future<List<Map<String, dynamic>>> getConfidenceHistory(String ideaId);
}
