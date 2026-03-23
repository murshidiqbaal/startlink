import 'package:startlink/features/aura/domain/entities/aura_activity.dart';

abstract class AuraRepository {
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic>? metadata,
  });

  Future<int> getTotalAura(String userId);
  Future<List<AuraActivity>> getHistory(String userId);

  Future<List<Map<String, dynamic>>> getLeaderboard(String role);
  Future<Map<String, dynamic>?> getWeeklySummary(String userId);

  /// Calculates and awards points for past actions (Ideas, Verification, etc.)
  /// that haven't been rewarded yet.
  Future<void> syncRetroactivePoints(String userId);
}
