class ProfileModel {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? headline;
  final String? about;
  final String? role;
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
    this.role,
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
      role: json['role'],
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
      'role': role,
      'skills': skills,
      'experience_level': experienceLevel,
      'education': education,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
    };
  }

  String get initials {
    if (fullName == null || fullName!.trim().isEmpty) {
      return '';
    }

    final names = fullName!.trim().split(RegExp(r'\s+'));
    if (names.isEmpty) return '';

    if (names.length == 1) {
      return names.first.isNotEmpty ? names.first[0].toUpperCase() : '';
    }

    return '${names.first[0]}${names.last[0]}'.toUpperCase();
  }

  ProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? about,
    String? role,
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
      role: role ?? this.role,
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
