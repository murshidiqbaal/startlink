import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';

class InnovatorProfileModel extends InnovatorProfile {
  const InnovatorProfileModel({
    required super.profileId,
    super.skills,
    super.experienceLevel,
    super.education,
    super.profileCompletion,
  });

  factory InnovatorProfileModel.fromJson(Map<String, dynamic> json) {
    return InnovatorProfileModel(
      profileId: json['profile_id'] as String,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : const [],
      experienceLevel: json['experience_level'] as String?,
      education: json['education'] as String?,
      profileCompletion: json['profile_completion'] ?? 0,
    );
  }

  factory InnovatorProfileModel.fromEntity(InnovatorProfile entity) {
    return InnovatorProfileModel(
      profileId: entity.profileId,
      skills: entity.skills,
      experienceLevel: entity.experienceLevel,
      education: entity.education,
      profileCompletion: entity.profileCompletion,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'skills': skills,
      'experience_level': experienceLevel,
      'education': education,
      'profile_completion': profileCompletion,
    };
  }

  InnovatorProfileModel copyWith({
    List<String>? skills,
    String? experienceLevel,
    String? education,
    int? profileCompletion,
  }) {
    return InnovatorProfileModel(
      profileId: profileId,
      skills: skills ?? this.skills,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      education: education ?? this.education,
      profileCompletion: profileCompletion ?? this.profileCompletion,
    );
  }
}
