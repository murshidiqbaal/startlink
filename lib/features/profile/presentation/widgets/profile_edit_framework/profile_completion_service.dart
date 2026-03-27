// lib/features/profile/presentation/widgets/profile_edit_framework/profile_completion_service.dart

import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';

class ProfileCompletionService {
  // ── Unified dispatcher (non-generic, safe runtime dispatch) ───────────────

  /// Calculates the completion score for any [RoleProfile] subtype.
  /// Uses `is` runtime checks — no unsafe casts, no generic parameters.
  static int calculate(RoleProfile p) {
    if (p is InvestorProfile) return calculateInvestor(p);
    if (p is MentorProfile) return calculateMentor(p);
    if (p is CollaboratorProfile) return calculateCollaborator(p);
    if (p is InnovatorProfile) return calculateInnovator(p);
    return 0;
  }

  // ── Role-specific calculators ─────────────────────────────────────────────

  static int calculateInvestor(InvestorProfile p) {
    int score = 0;
    if (_has(p.investmentFocus)) score += 20;
    if (p.ticketSizeMin != null && p.ticketSizeMax != null) score += 20;
    if (_has(p.preferredStage)) score += 20;
    if (_has(p.organizationName)) score += 15;
    if (_has(p.linkedinUrl)) score += 15;
    if (_has(p.bio)) score += 10;
    return score;
  }

  static int calculateMentor(MentorProfile p) {
    int total = 5;
    int filled = 0;

    if (p.expertise.isNotEmpty) filled++;
    if (p.yearsExperience != null) filled++;
    if (_has(p.bio)) filled++;
    if (_has(p.linkedinUrl)) filled++;
    if (_has(p.availability)) filled++;

    return (filled / total * 100).toInt();
  }

  static int calculateCollaborator(CollaboratorProfile p) {
    int score = 0;
    if (p.specialties.isNotEmpty) score += 20;
    if (_has(p.availability)) score += 15;
    if (p.experienceYears != null) score += 15;
    if (_has(p.portfolioUrl)) score += 15;
    if (_has(p.linkedinUrl)) score += 15;
    if (_has(p.githubUrl)) score += 10;
    if (_has(p.bio)) score += 10;
    return score;
  }

  static int calculateInnovator(InnovatorProfile p) {
    int score = 0;
    if (p.skills.isNotEmpty) score += 20;
    if (_has(p.bio)) score += 15;
    if (_has(p.experienceLevel)) score += 10;
    if (_has(p.education)) score += 10;
    if (_has(p.startupName)) score += 15;
    if (_has(p.linkedinUrl)) score += 15;
    if (_has(p.githubUrl)) score += 15;
    return score;
  }

  static bool _has(String? v) => v != null && v.trim().isNotEmpty;
}
