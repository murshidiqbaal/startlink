import 'package:startlink/features/achievements/domain/entities/achievement.dart';

abstract class AchievementRepository {
  Future<List<Achievement>> getAchievements(String userId);
  Future<void> evaluateAndAward(String userId, String eventKey);
}
