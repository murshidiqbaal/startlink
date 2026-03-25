// lib/features/profile/presentation/widgets/profile_edit_framework/profile_completion_service.dart

import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';

class ProfileCompletionService {
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
    int score = 0;
    if (p.expertiseDomains.isNotEmpty) score += 30;
    if (p.yearsOfExperience != null) score += 20;
    if (_has(p.mentorshipFocus)) score += 30;
    if (_has(p.linkedinUrl)) score += 20;
    return score;
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
