import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';

class MentorProfileModel extends MentorProfile {
  const MentorProfileModel({
    required super.profileId,
    super.expertiseDomains = const [],
    super.yearsOfExperience,
    super.mentorshipFocus,
    super.linkedinUrl,
    super.certifications = const [],
    super.profileCompletion = 0,
    super.isVerified = false,
  });

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

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) =>
      MentorProfileModel(
        profileId: json['profile_id'] as String,
        expertiseDomains: _toStrList(json['expertise_domains']),
        yearsOfExperience: (json['years_of_experience'] as num?)?.toInt(),
        mentorshipFocus: json['mentorship_focus'] as String?,
        linkedinUrl: json['linkedin_url'] as String?,
        certifications: _toStrList(json['certifications']),
        profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
        isVerified: (json['is_verified'] as bool?) ?? false,
      );

  Map<String, dynamic> toUpsertJson() => {
    'profile_id': profileId,
    'expertise_domains': expertiseDomains,
    'years_of_experience': yearsOfExperience,
    'mentorship_focus': mentorshipFocus,
    'linkedin_url': linkedinUrl,
    'certifications': certifications,
    'profile_completion': profileCompletion,
  };

  MentorProfileModel copyWith({
    List<String>? expertiseDomains,
    int? yearsOfExperience,
    String? mentorshipFocus,
    String? linkedinUrl,
    List<String>? certifications,
    int? profileCompletion,
  }) => MentorProfileModel(
    profileId: profileId,
    expertiseDomains: expertiseDomains ?? this.expertiseDomains,
    yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
    mentorshipFocus: mentorshipFocus ?? this.mentorshipFocus,
    linkedinUrl: linkedinUrl ?? this.linkedinUrl,
    certifications: certifications ?? this.certifications,
    profileCompletion: profileCompletion ?? this.profileCompletion,
    isVerified: isVerified,
  );

  static List<String> _toStrList(dynamic v) =>
      (v as List?)?.map((e) => e.toString()).toList() ?? [];
}
