import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';

class CollaboratorProfileModel extends CollaboratorProfile {
  const CollaboratorProfileModel({
    required super.profileId,
    super.specialties = const [],
    super.availability,
    super.experienceYears,
    super.preferredProjectTypes = const [],
    super.bio,
    super.portfolioUrl,
    super.githubUrl,
    super.linkedinUrl,
    super.resumeUrl,
    super.hourlyRate,
    super.profileCompletion = 0,
  });

  factory CollaboratorProfileModel.fromEntity(CollaboratorProfile entity) {
    return CollaboratorProfileModel(
      profileId: entity.profileId,
      specialties: entity.specialties,
      availability: entity.availability,
      experienceYears: entity.experienceYears,
      preferredProjectTypes: entity.preferredProjectTypes,
      bio: entity.bio,
      portfolioUrl: entity.portfolioUrl,
      githubUrl: entity.githubUrl,
      linkedinUrl: entity.linkedinUrl,
      resumeUrl: entity.resumeUrl,
      hourlyRate: entity.hourlyRate,
      profileCompletion: entity.profileCompletion,
    );
  }

  factory CollaboratorProfileModel.fromJson(Map<String, dynamic> json) {
    return CollaboratorProfileModel(
      profileId: json['profile_id'] as String,
      specialties: List<String>.from(json['specialties'] ?? []),
      availability: json['availability'] as String?,
      experienceYears: (json['experience_years'] as num?)?.toInt(),
      preferredProjectTypes:
          List<String>.from(json['preferred_project_types'] ?? []),
      bio: json['bio'] as String?,
      portfolioUrl: json['portfolio_url'] as String?,
      githubUrl: json['github_url'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      resumeUrl: json['resume_url'] as String?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toUpsertJson() => {
    'profile_id': profileId,
    'specialties': specialties,
    'availability': availability,
    'experience_years': experienceYears,
    'preferred_project_types': preferredProjectTypes,
    'bio': bio,
    'portfolio_url': portfolioUrl,
    'github_url': githubUrl,
    'linkedin_url': linkedinUrl,
    'resume_url': resumeUrl,
    'hourly_rate': hourlyRate,
    'profile_completion': profileCompletion,
  };

  CollaboratorProfileModel copyWith({
    List<String>? specialties,
    String? availability,
    int? experienceYears,
    List<String>? preferredProjectTypes,
    String? bio,
    String? portfolioUrl,
    String? githubUrl,
    String? linkedinUrl,
    String? resumeUrl,
    double? hourlyRate,
    int? profileCompletion,
  }) => CollaboratorProfileModel(
    profileId: profileId,
    specialties: specialties ?? this.specialties,
    availability: availability ?? this.availability,
    experienceYears: experienceYears ?? this.experienceYears,
    preferredProjectTypes: preferredProjectTypes ?? this.preferredProjectTypes,
    bio: bio ?? this.bio,
    portfolioUrl: portfolioUrl ?? this.portfolioUrl,
    githubUrl: githubUrl ?? this.githubUrl,
    linkedinUrl: linkedinUrl ?? this.linkedinUrl,
    resumeUrl: resumeUrl ?? this.resumeUrl,
    hourlyRate: hourlyRate ?? this.hourlyRate,
    profileCompletion: profileCompletion ?? this.profileCompletion,
  );

}
