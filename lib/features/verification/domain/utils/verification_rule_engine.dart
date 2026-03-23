import 'package:startlink/features/verification/domain/repositories/verification_repository.dart';

class VerificationRuleEngine {
  final VerificationRepository _repository;

  VerificationRuleEngine(this._repository);

  /// Checks if the user qualifies for the 'profile_verified' badge and awards it if so.
  /// Also handles 'trusted_mentor' and 'verified_investor' logic triggers.
  Future<void> evaluateProfileBadges(
    String profileId,
    String? role,
    int completionScore,
    bool
    isRoleVerified, // From Supabase role specific table (e.g. mentor_profiles.is_verified)
  ) async {
    // 1. Profile Verified Badge (General)
    if (completionScore >= 80) {
      await _repository.awardBadge(
        profileId: profileId,
        badgeKey: 'profile_verified',
        label: 'Verified Profile',
        description: 'High quality profile completion.',
      );
    }

    // 2. Role Specific Badges
    if (isRoleVerified) {
      if (role == 'Mentor') {
        await _repository.awardBadge(
          profileId: profileId,
          badgeKey: 'trusted_mentor',
          label: 'Trusted Mentor',
          description: 'Verified Identity and Expertise.',
        );
      } else if (role == 'Investor') {
        await _repository.awardBadge(
          profileId: profileId,
          badgeKey: 'verified_investor',
          label: 'Verified Investor',
          description: 'Accredited and Verified Identity.',
        );
      }
    }
  }

  // Future expansion: Evaluate activity badges (active_innovator)
  // Future<void> evaluateActivityBadges(...) async {}
}
