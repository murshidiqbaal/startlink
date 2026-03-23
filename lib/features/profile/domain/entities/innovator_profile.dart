import 'package:equatable/equatable.dart';

/// Domain entity for the `innovator_profiles` Supabase table.
class InnovatorProfile extends Equatable {
  final String profileId;

  // ── Professional Snapshot ────────────────────────────────────────────────
  final List<String> skills;
  final String? bio;
  final String? experienceLevel; // '<1yr', '1-3yr', '3-5yr', '5+yr', '10+yr'
  final String? currentStatus; // 'Student', 'Working', 'Building Startup'
  final String? education;

  // ── Startup Credibility ───────────────────────────────────────────────────
  final bool buildingStartup;
  final String? startupName;
  final String? portfolioUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? resumeUrl;
  final String? twitterUrl;

  // ── Collaboration Preferences ─────────────────────────────────────────────
  final bool openToCofounder;
  final bool openToInvestors;
  final bool openToMentors;
  final String? preferredWorkMode; // 'Remote', 'Hybrid', 'Onsite'

  // ── Completion ────────────────────────────────────────────────────────────
  final int profileCompletion;

  const InnovatorProfile({
    required this.profileId,
    this.skills = const [],
    this.bio,
    this.experienceLevel,
    this.currentStatus,
    this.education,
    this.buildingStartup = false,
    this.startupName,
    this.portfolioUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.resumeUrl,
    this.twitterUrl,
    this.openToCofounder = false,
    this.openToInvestors = false,
    this.openToMentors = false,
    this.preferredWorkMode,
    this.profileCompletion = 0,
  });

  @override
  List<Object?> get props => [
    profileId,
    skills,
    bio,
    experienceLevel,
    currentStatus,
    education,
    buildingStartup,
    startupName,
    portfolioUrl,
    githubUrl,
    linkedinUrl,
    resumeUrl,
    twitterUrl,
    openToCofounder,
    openToInvestors,
    openToMentors,
    preferredWorkMode,
    profileCompletion,
  ];
}
