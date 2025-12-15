class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? headline;
  final String? about;
  final List<String> skills;
  final String? experienceLevel;
  final String? education;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String? githubUrl;
  final int profileCompletion;

  const ProfileModel({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.headline,
    this.about,
    this.skills = const [],
    this.experienceLevel,
    this.education,
    this.portfolioUrl,
    this.linkedinUrl,
    this.githubUrl,
    this.profileCompletion = 0,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      headline: json['headline'],
      about: json['about'],
      skills: json['skills'] != null ? List<String>.from(json['skills']) : [],
      experienceLevel: json['experience_level'],
      education: json['education'],
      portfolioUrl: json['portfolio_url'],
      linkedinUrl: json['linkedin_url'],
      githubUrl: json['github_url'],
      profileCompletion: json['profile_completion'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'headline': headline,
      'about': about,
      'skills': skills,
      'experience_level': experienceLevel,
      'education': education,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'profile_completion': profileCompletion,
    };
  }

  ProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? about,
    List<String>? skills,
    String? experienceLevel,
    String? education,
    String? portfolioUrl,
    String? linkedinUrl,
    String? githubUrl,
    int? profileCompletion,
  }) {
    return ProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      headline: headline ?? this.headline,
      about: about ?? this.about,
      skills: skills ?? this.skills,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      education: education ?? this.education,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      profileCompletion: profileCompletion ?? this.profileCompletion,
    );
  }
}
