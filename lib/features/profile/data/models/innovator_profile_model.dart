import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';

class InnovatorProfileModel extends InnovatorProfile {
  const InnovatorProfileModel({
    required super.profileId,
    super.skills,
    super.bio,
    super.experienceLevel,
    super.currentStatus,
    super.education,
    super.buildingStartup,
    super.startupName,
    super.portfolioUrl,
    super.githubUrl,
    super.linkedinUrl,
    super.resumeUrl,
    super.twitterUrl,
    super.openToCofounder,
    super.openToInvestors,
    super.openToMentors,
    super.preferredWorkMode,
    super.profileCompletion,
  });

  factory InnovatorProfileModel.fromJson(Map<String, dynamic> json) {
    return InnovatorProfileModel(
      profileId: json['profile_id'] as String,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'] as List)
          : const [],
      bio: json['bio'] as String?,
      experienceLevel: json['experience_level'] as String?,
      currentStatus: json['current_status'] as String?,
      education: json['education'] as String?,
      buildingStartup: json['building_startup'] as bool? ?? false,
      startupName: json['startup_name'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      githubUrl: json['github_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      resumeUrl: json['resume_url'] as String?,
      twitterUrl: json['twitter_url'] as String?,
      openToCofounder: json['open_to_cofounder'] as bool? ?? false,
      openToInvestors: json['open_to_investors'] as bool? ?? false,
      openToMentors: json['open_to_mentors'] as bool? ?? false,
      preferredWorkMode: json['preferred_work_mode'] as String?,
      profileCompletion: json['profile_completion'] as int? ?? 0,
    );
  }

  factory InnovatorProfileModel.fromEntity(InnovatorProfile entity) {
    return InnovatorProfileModel(
      profileId: entity.profileId,
      skills: entity.skills,
      bio: entity.bio,
      experienceLevel: entity.experienceLevel,
      currentStatus: entity.currentStatus,
      education: entity.education,
      buildingStartup: entity.buildingStartup,
      startupName: entity.startupName,
      portfolioUrl: entity.portfolioUrl,
      githubUrl: entity.githubUrl,
      linkedinUrl: entity.linkedinUrl,
      resumeUrl: entity.resumeUrl,
      twitterUrl: entity.twitterUrl,
      openToCofounder: entity.openToCofounder,
      openToInvestors: entity.openToInvestors,
      openToMentors: entity.openToMentors,
      preferredWorkMode: entity.preferredWorkMode,
      profileCompletion: entity.profileCompletion,
    );
  }

  /// Only non-null values are written; null fields are not sent to Supabase.
  Map<String, dynamic> toUpsertJson() {
    final map = <String, dynamic>{
      'profile_id': profileId,
      'skills': skills,
      'building_startup': buildingStartup,
      'open_to_cofounder': openToCofounder,
      'open_to_investors': openToInvestors,
      'open_to_mentors': openToMentors,
      'profile_completion': profileCompletion,
    };
    if (bio != null) map['bio'] = bio;
    if (experienceLevel != null) map['experience_level'] = experienceLevel;
    if (currentStatus != null) map['current_status'] = currentStatus;
    if (education != null) map['education'] = education;
    if (startupName != null) map['startup_name'] = startupName;
    if (portfolioUrl != null) map['portfolio_url'] = portfolioUrl;
    if (githubUrl != null) map['github_url'] = githubUrl;
    if (linkedinUrl != null) map['linkedin_url'] = linkedinUrl;
    if (resumeUrl != null) map['resume_url'] = resumeUrl;
    if (twitterUrl != null) map['twitter_url'] = twitterUrl;
    if (preferredWorkMode != null)
      map['preferred_work_mode'] = preferredWorkMode;
    return map;
  }

  InnovatorProfileModel copyWith({
    List<String>? skills,
    String? bio,
    String? experienceLevel,
    String? currentStatus,
    String? education,
    bool? buildingStartup,
    String? startupName,
    String? portfolioUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? resumeUrl,
    String? twitterUrl,
    bool? openToCofounder,
    bool? openToInvestors,
    bool? openToMentors,
    String? preferredWorkMode,
    int? profileCompletion,
  }) {
    return InnovatorProfileModel(
      profileId: profileId,
      skills: skills ?? this.skills,
      bio: bio ?? this.bio,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      currentStatus: currentStatus ?? this.currentStatus,
      education: education ?? this.education,
      buildingStartup: buildingStartup ?? this.buildingStartup,
      startupName: startupName ?? this.startupName,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      twitterUrl: twitterUrl ?? this.twitterUrl,
      openToCofounder: openToCofounder ?? this.openToCofounder,
      openToInvestors: openToInvestors ?? this.openToInvestors,
      openToMentors: openToMentors ?? this.openToMentors,
      preferredWorkMode: preferredWorkMode ?? this.preferredWorkMode,
      profileCompletion: profileCompletion ?? this.profileCompletion,
    );
  }
}
