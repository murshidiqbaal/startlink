import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';

class ProfileCompletionCalculator {
  // ── Innovator completion ────────────────────────────────────────────────
  // Profile (from `profiles` table) + Innovator (from `innovator_profiles`)
  // Max = 100
  static int calculateInnovatorCompletion(
    ProfileModel base,
    InnovatorProfile? role,
  ) {
    int score = 0;

    // Required fields — heavy weight (total 60)
    if (base.fullName != null && base.fullName!.isNotEmpty) score += 20;
    if (base.avatarUrl != null && base.avatarUrl!.isNotEmpty) score += 20;
    if (base.headline != null && base.headline!.isNotEmpty) score += 15;
    if (base.role != null && base.role!.isNotEmpty) score += 5;

    // Optional — high value (total 40)
    if (role != null) {
      if (role.bio != null && role.bio!.isNotEmpty) score += 10;
      if (role.skills.isNotEmpty) score += 10;
      if (role.experienceLevel != null && role.experienceLevel!.isNotEmpty) {
        score += 5;
      }
      if (role.currentStatus != null && role.currentStatus!.isNotEmpty) {
        score += 5;
      }
      if (role.linkedinUrl != null && role.linkedinUrl!.isNotEmpty) score += 5;
      if (role.portfolioUrl != null && role.portfolioUrl!.isNotEmpty) {
        score += 5;
      }
    }

    return score.clamp(0, 100);
  }

  /// Returns a list of human-readable missing field hints for the profile.
  static List<String> missingHints({
    required ProfileModel base,
    required InnovatorProfile? role,
  }) {
    final hints = <String>[];
    if (base.fullName == null || base.fullName!.isEmpty) {
      hints.add('Add your full name');
    }
    if (base.avatarUrl == null || base.avatarUrl!.isEmpty) {
      hints.add('Upload a profile photo');
    }
    if (base.headline == null || base.headline!.isEmpty) {
      hints.add('Write a one-line headline');
    }
    if (role == null || role.bio == null || role.bio!.isEmpty) {
      hints.add('Add a short bio');
    }
    if (role == null || role.skills.isEmpty) {
      hints.add('Add your skills');
    }
    if (role == null || role.linkedinUrl == null || role.linkedinUrl!.isEmpty) {
      hints.add('Link your LinkedIn profile');
    }
    return hints;
  }

  // ── Mentor completion ───────────────────────────────────────────────────
  static int calculateMentorCompletion(
    dynamic baseProfile,
    MentorProfile? roleProfile,
  ) {
    if (roleProfile == null) return 0;
    int score = 0;
    if (roleProfile.expertiseDomains.isNotEmpty) score += 30;
    if (roleProfile.yearsOfExperience != null &&
        roleProfile.yearsOfExperience! > 0)
      score += 20;
    if (roleProfile.linkedinUrl != null &&
        roleProfile.linkedinUrl!.isNotEmpty) {
      score += 20;
    }
    if (roleProfile.mentorshipFocus != null &&
        roleProfile.mentorshipFocus!.isNotEmpty)
      score += 30;
    return score.clamp(0, 100);
  }

  // ── Investor completion ─────────────────────────────────────────────────
  static int calculateInvestorCompletion(
    dynamic baseProfile,
    InvestorProfile? roleProfile,
  ) {
    if (roleProfile == null) return 0;
    int score = 0;
    if (roleProfile.investmentFocus != null &&
        roleProfile.investmentFocus!.isNotEmpty)
      score += 20;
    if (roleProfile.ticketSizeMin != null ||
        roleProfile.ticketSizeMax != null) {
      score += 20;
    }
    if (roleProfile.preferredStage != null &&
        roleProfile.preferredStage!.isNotEmpty)
      score += 20;
    if (roleProfile.organizationName != null &&
        roleProfile.organizationName!.isNotEmpty)
      score += 20;
    if (roleProfile.linkedinUrl != null &&
        roleProfile.linkedinUrl!.isNotEmpty) {
      score += 20;
    }
    return score.clamp(0, 100);
  }

  static bool isInnovatorComplete(ProfileModel base, InnovatorProfile? role) {
    return calculateInnovatorCompletion(base, role) >= 70;
  }

  static bool isMentorComplete(dynamic base, MentorProfile? role) {
    return calculateMentorCompletion(base, role) >= 80;
  }

  static bool isInvestorComplete(dynamic base, InvestorProfile? role) {
    return calculateInvestorCompletion(base, role) >= 85;
  }

  // Legacy method (for ProfileBloc.UpdateProfile which only has ProfileModel)
  static int calculate(ProfileModel profile) {
    int score = 0;
    if (profile.fullName != null && profile.fullName!.isNotEmpty) score += 15;
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) score += 15;
    if (profile.headline != null && profile.headline!.isNotEmpty) score += 15;
    if (profile.about != null && profile.about!.isNotEmpty) score += 10;
    if (profile.skills.isNotEmpty) score += 15;
    if (profile.experienceLevel != null && profile.experienceLevel!.isNotEmpty)
      score += 10;
    if (profile.linkedinUrl != null && profile.linkedinUrl!.isNotEmpty) {
      score += 10;
    }
    if (profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty) {
      score += 5;
    }
    if (profile.githubUrl != null && profile.githubUrl!.isNotEmpty) score += 5;
    return score.clamp(0, 100);
  }
}
