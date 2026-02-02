import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/user_profile.dart';

class ProfileCompletionCalculator {
  static int calculateInnovatorCompletion(
    UserProfile baseProfile,
    InnovatorProfile? roleProfile,
  ) {
    if (roleProfile == null) return 0;

    int currentScore = 0;

    // Required: skills, about, profile photo
    // Let's assign weights. Total 100.
    // Photo: 20, About: 20, Skills: 60 (Crucial for innovator)

    // Base Profile Checks
    if (baseProfile.profilePhoto != null &&
        baseProfile.profilePhoto!.isNotEmpty) {
      currentScore += 20;
    }
    if (baseProfile.about != null && baseProfile.about!.isNotEmpty) {
      currentScore += 20;
    }

    // Role Profile Checks
    if (roleProfile.skills.isNotEmpty) {
      currentScore += 60;
    }

    // You can refine this logic. For now, simple presence.
    return currentScore;
  }

  static int calculateMentorCompletion(
    UserProfile baseProfile,
    MentorProfile? roleProfile,
  ) {
    if (roleProfile == null) return 0;
    int currentScore = 0;
    // Required: Expertise domains, Years of experience, LinkedIn, Mentorship focus
    // Weights: Expertise: 30, YOE: 20, LinkedIn: 20, Focus: 30

    if (roleProfile.expertiseDomains.isNotEmpty) currentScore += 30;
    if (roleProfile.yearsOfExperience != null &&
        roleProfile.yearsOfExperience! > 0) {
      currentScore += 20;
    }
    if (roleProfile.linkedinUrl != null &&
        roleProfile.linkedinUrl!.isNotEmpty) {
      currentScore += 20;
    }
    if (roleProfile.mentorshipFocus != null &&
        roleProfile.mentorshipFocus!.isNotEmpty) {
      currentScore += 30;
    }

    return currentScore;
  }

  static int calculateInvestorCompletion(
    UserProfile baseProfile,
    InvestorProfile? roleProfile,
  ) {
    if (roleProfile == null) return 0;
    int currentScore = 0;

    // Required: Investment focus, Ticket size, Preferred stage, Organization, LinkedIn
    // Weights: Focus: 20, Ticket: 20, Stage: 20, Org: 20, LinkedIn: 20

    if (roleProfile.investmentFocus != null &&
        roleProfile.investmentFocus!.isNotEmpty) {
      currentScore += 20;
    }
    if (roleProfile.ticketSizeMin != null ||
        roleProfile.ticketSizeMax != null) {
      currentScore += 20;
    }
    if (roleProfile.preferredStage != null &&
        roleProfile.preferredStage!.isNotEmpty) {
      currentScore += 20;
    }
    if (roleProfile.organizationName != null &&
        roleProfile.organizationName!.isNotEmpty) {
      currentScore += 20;
    }
    if (roleProfile.linkedinUrl != null &&
        roleProfile.linkedinUrl!.isNotEmpty) {
      currentScore += 20;
    }

    return currentScore;
  }

  static bool isInnovatorComplete(UserProfile base, InnovatorProfile? role) {
    return calculateInnovatorCompletion(base, role) >= 70;
  }

  static bool isMentorComplete(UserProfile base, MentorProfile? role) {
    return calculateMentorCompletion(base, role) >= 80;
  }

  static bool isInvestorComplete(UserProfile base, InvestorProfile? role) {
    return calculateInvestorCompletion(base, role) >= 85;
  }

  // Legacy support for ProfileModel
  static int calculate(ProfileModel profile) {
    int score = 0;
    if (profile.fullName != null && profile.fullName!.isNotEmpty) score += 10;
    if (profile.headline != null && profile.headline!.isNotEmpty) score += 10;
    if (profile.about != null && profile.about!.isNotEmpty) score += 20;
    if (profile.skills.isNotEmpty) score += 20;
    if (profile.education != null && profile.education!.isNotEmpty) score += 10;
    if (profile.experienceLevel != null &&
        profile.experienceLevel!.isNotEmpty) {
      score += 10;
    }
    if (profile.linkedinUrl != null && profile.linkedinUrl!.isNotEmpty) {
      score += 20;
    }
    // Cap at 100
    return score > 100 ? 100 : score;
  }
}
