// lib/features/profile/data/models/profile_model.dart

class ProfileModel {
  final String id; // profiles.id  (PK — NOT auth.users.id)
  final String? userId; // profiles.user_id (FK → auth.users.id)
  final String? fullName;
  final String? avatarUrl;
  final String? headline;
  final String? location;
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
    this.userId,
    this.fullName,
    this.avatarUrl,
    this.headline,
    this.location,
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

  // ── Computed ──────────────────────────────────────────────────────────────

  String get initials {
    final name = fullName?.trim() ?? '';
    if (name.isEmpty) return '';
    final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  // ── JSON ──────────────────────────────────────────────────────────────────

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    userId: json['user_id'] as String?,
    fullName: json['full_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    headline: json['headline'] as String?,
    location: json['location'] as String?,
    about: json['about'] as String?,
    role: json['role'] as String?,
    skills: _toStrList(json['skills']),
    experienceLevel: json['experience_level'] as String?,
    education: json['education'] as String?,
    portfolioUrl: json['portfolio_url'] as String?,
    linkedinUrl: json['linkedin_url'] as String?,
    githubUrl: json['github_url'] as String?,
    profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'headline': headline,
    'location': location,
    'about': about,
    'role': role,
    'skills': skills,
    'experience_level': experienceLevel,
    'education': education,
    'portfolio_url': portfolioUrl,
    'linkedin_url': linkedinUrl,
    'github_url': githubUrl,
    'profile_completion': profileCompletion,
  };

  /// Only fields that can be updated by the user (never id / user_id / timestamps)
  Map<String, dynamic> toUpdateJson() => {
    'full_name': fullName,
    'avatar_url': avatarUrl,
    'headline': headline,
    'location': location,
    'about': about,
    'role': role,
    'skills': skills,
    'experience_level': experienceLevel,
    'education': education,
    'portfolio_url': portfolioUrl,
    'linkedin_url': linkedinUrl,
    'github_url': githubUrl,
    'profile_completion': profileCompletion,
  };

  // ── copyWith ──────────────────────────────────────────────────────────────

  ProfileModel copyWith({
    String? fullName,
    String? avatarUrl,
    String? headline,
    String? location,
    String? about,
    String? role,
    List<String>? skills,
    String? experienceLevel,
    String? education,
    String? portfolioUrl,
    String? linkedinUrl,
    String? githubUrl,
    int? profileCompletion,
  }) => ProfileModel(
    id: id,
    userId: userId,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    headline: headline ?? this.headline,
    location: location ?? this.location,
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

  static List<String> _toStrList(dynamic v) =>
      (v as List?)?.map((e) => e.toString()).toList() ?? [];
}
