import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';

class MentorProfileModel extends MentorProfile {
  const MentorProfileModel({
    required super.profileId,
    super.expertiseDomains,
    super.yearsOfExperience,
    super.mentorshipFocus,
    super.linkedinUrl,
    super.certifications,
    super.profileCompletion,
    super.isVerified,
  });

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) {
    return MentorProfileModel(
      profileId: json['profile_id'] as String,
      expertiseDomains: json['expertise_domains'] != null
          ? List<String>.from(json['expertise_domains'])
          : const [],
      yearsOfExperience: json['years_of_experience'] as int?,
      mentorshipFocus: json['mentorship_focus'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'])
          : const [],
      profileCompletion: json['profile_completion'] ?? 0,
      isVerified: json['is_verified'] ?? false,
    );
  }

  factory MentorProfileModel.fromEntity(MentorProfile entity) {
    return MentorProfileModel(
      profileId: entity.profileId,
      expertiseDomains: entity.expertiseDomains,
      yearsOfExperience: entity.yearsOfExperience,
      mentorshipFocus: entity.mentorshipFocus,
      linkedinUrl: entity.linkedinUrl,
      certifications: entity.certifications,
      profileCompletion: entity.profileCompletion,
      isVerified: entity.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'expertise_domains': expertiseDomains,
      'years_of_experience': yearsOfExperience,
      'mentorship_focus': mentorshipFocus,
      'linkedin_url': linkedinUrl,
      'certifications': certifications,
      'profile_completion': profileCompletion,
      'is_verified': isVerified,
    };
  }

  MentorProfileModel copyWith({
    List<String>? expertiseDomains,
    int? yearsOfExperience,
    String? mentorshipFocus,
    String? linkedinUrl,
    List<String>? certifications,
    int? profileCompletion,
    bool? isVerified,
  }) {
    return MentorProfileModel(
      profileId: profileId,
      expertiseDomains: expertiseDomains ?? this.expertiseDomains,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      mentorshipFocus: mentorshipFocus ?? this.mentorshipFocus,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      certifications: certifications ?? this.certifications,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
