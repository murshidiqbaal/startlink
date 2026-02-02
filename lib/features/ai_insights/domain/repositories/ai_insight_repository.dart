import 'package:startlink/features/ai_insights/domain/entities/ai_insight.dart';

abstract class AIInsightRepository {
  Future<AIInsight> getInsight(String ideaId, String investorId);
  Future<void> analyzeIdea(String ideaId);
}
