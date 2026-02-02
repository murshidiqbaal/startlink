abstract class TrustRepository {
  Future<int> getTrustScore(String profileId);
  Future<void> updateTrustScore(String profileId, String role, int score);
}
