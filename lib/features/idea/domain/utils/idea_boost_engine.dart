class IdeaBoostEngine {
  static bool shouldBoost({
    required int trustScore,
    required bool isVerified, // Profile Verified
    required String status, // 'Published'
  }) {
    // Boost conditions: Trust Score >= 120 AND (Verified OR Trust Score >= 150)
    // Actually simplicity from prompt: "Boost if Owner Verified AND Trust > 120 AND Published"

    if (status != 'Published') return false;

    // Strict from prompt conditions:
    // 1. Owner is verified
    // 2. Trust score >= 120

    return isVerified && trustScore >= 120;
  }

  static int calculateBoostScore(int trustScore) {
    return (trustScore / 2).floor();
  }
}
