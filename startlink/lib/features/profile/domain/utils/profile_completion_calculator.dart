import 'package:startlink/features/profile/data/models/profile_model.dart';

class ProfileCompletionCalculator {
  static int calculate(ProfileModel profile) {
    double score = 0;

    // Mandatory - 60%
    if (_hasValue(profile.fullName)) score += 10;
    if (_hasValue(profile.avatarUrl)) score += 15;
    if (_hasValue(profile.headline)) score += 10;
    // Location is not in our model yet, assuming mapped or skipped for now?
    // Let's assume 'about' covers location context or add it later.
    // Adjusted weights based on available fields:
    // Full Name: 10, Photo: 15, Headline: 10, About: 25 (total 60)
    if (_hasValue(profile.about)) score += 25;

    // Professional - 30%
    if (profile.skills.isNotEmpty) score += 15;
    if (_hasValue(profile.experienceLevel)) score += 10;
    if (_hasValue(profile.education)) score += 5;

    // Trust - 10%
    if (_hasValue(profile.portfolioUrl) ||
        _hasValue(profile.linkedinUrl) ||
        _hasValue(profile.githubUrl)) {
      score += 10;
    }

    return score.toInt().clamp(0, 100);
  }

  static bool _hasValue(String? value) {
    return value != null && value.isNotEmpty;
  }
}
