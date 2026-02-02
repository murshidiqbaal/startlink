import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';

class MatchScoreCalculator {
  static const double _weightSkills = 0.40;
  static const double _weightTrust = 0.25;
  static const double _weightAura = 0.15;
  static const double _weightRecency = 0.10;
  static const double _weightRole = 0.10; // Bonus for explicit role match

  // Returns a score 0-100 and a reason map
  static Map<String, dynamic> calculate(
    Idea idea,
    ProfileModel userProfile,
    int userTrustScore,
    int userAuraPoints,
  ) {
    double score = 0;
    List<String> reasonSkills = [];
    String reasonTrust = '';
    String reasonActivity = '';

    // 1. Skill Match (40%)
    double skillScore = 0;
    if (idea.tags.isNotEmpty && userProfile.skills.isNotEmpty) {
      final ideaSkillsLower = idea.tags.map((e) => e.toLowerCase()).toSet();
      final userSkillsLower = userProfile.skills
          .map((e) => e.toLowerCase())
          .toSet();
      final intersection = ideaSkillsLower.intersection(userSkillsLower);

      if (intersection.isNotEmpty) {
        skillScore = (intersection.length / idea.tags.length) * 100;
        if (skillScore > 100) skillScore = 100;
        reasonSkills = intersection.take(3).toList();
      }
    }
    score += skillScore * _weightSkills;

    // 2. Trust Score (25%) -> Normalize 0-200 to 0-100
    // Assuming trust score can go high, let's cap normalization at 100 for score calculation
    double trust = userTrustScore.toDouble();
    if (trust > 100) trust = 100;
    score += trust * _weightTrust;
    if (userTrustScore > 50) reasonTrust = 'High Trust';

    // 3. Aura Points (15%) -> Normalize, say cap at 1000 Aura = 100 pts
    double aura = (userAuraPoints / 1000) * 100;
    if (aura > 100) aura = 100;
    score += aura * _weightAura;

    // 4. Activity Recency (10%)
    // Since we don't have last_active in ProfileModel yet (assuming), let's simulate or use updated_at if available in db but model needs it.
    // For MVP light, let's give default partial points or updated logic later.
    // Let's assume ProfileModel has nothing relative, so we skip exact calc or assume active if in list.
    score += 80 * _weightRecency; // Assume 'active recently' for candidate pool
    reasonActivity = 'Active recently';

    // 5. Role Relevance (10%)
    // Ideally we match Mentors to Mentor requests, etc.
    // If user has role 'Mentor' and idea needs mentorship, full points.
    // Current Idea entity doesn't explicitly ask for 'Mentors' vs 'Co-founders', usually implied.
    // We'll give flat bonus for now.
    score += 100 * _weightRole;

    return {
      'score': score.round(),
      'reason': {
        'skills': reasonSkills,
        'trust_reason': reasonTrust,
        'activity_reason': reasonActivity,
        'aura_points': userAuraPoints,
        'trust_score': userTrustScore,
      },
    };
  }
}
