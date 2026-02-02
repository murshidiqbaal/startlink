class TrustScoreCalculator {
  static int calculate({
    required int completion,
    required bool isVerified, // Profile Verified badge
    required bool isRoleVerified, // Trusted Mentor / Verified Investor
    required int ideaCount,
    required int collabCount,
  }) {
    int score = 0;

    // Profile Completion
    if (completion >= 90) {
      score += 40;
    } else if (completion >= 80) {
      score += 30;
    } else if (completion >= 70) {
      score += 20;
    }

    // Verification
    if (isVerified) score += 30;
    if (isRoleVerified) score += 40;

    // Activity
    score += (ideaCount * 10).clamp(0, 30); // Max 30
    score += (collabCount * 10).clamp(0, 20); // Max 20

    return score.clamp(0, 200);
  }
}
