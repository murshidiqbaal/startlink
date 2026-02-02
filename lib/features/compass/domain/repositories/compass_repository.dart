import 'package:startlink/features/compass/domain/entities/compass_recommendation.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';

abstract class CompassRepository {
  Future<List<CompassRecommendation>> getRecommendations(String profileId);
  Future<void> recalculateRecommendations(
    ProfileModel profile, {
    List<Idea>? ideas,
  });
}
