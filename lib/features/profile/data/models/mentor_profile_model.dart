import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';

class MentorProfileModel extends MentorProfile {
  const MentorProfileModel({
    required super.profileId,
    super.expertise = const [],
    super.yearsExperience,
    super.bio,
    super.linkedinUrl,
    super.availability,
    super.profileCompletion = 0,
    super.isVerified = false,
  });

  factory MentorProfileModel.fromEntity(MentorProfile entity) {
    return MentorProfileModel(
      profileId: entity.profileId,
      expertise: entity.expertise,
      yearsExperience: entity.yearsExperience,
      bio: entity.bio,
      linkedinUrl: entity.linkedinUrl,
      availability: entity.availability,
      profileCompletion: entity.profileCompletion,
      isVerified: entity.isVerified,
    );
  }

  factory MentorProfileModel.fromJson(Map<String, dynamic> json) =>
      MentorProfileModel(
        profileId: json['profile_id'] as String,
        expertise: _toStrList(json['expertise']),
        yearsExperience: (json['years_experience'] as num?)?.toInt(),
        bio: json['bio'] as String?,
        linkedinUrl: json['linkedin_url'] as String?,
        availability: json['availability'] as String?,
        profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
        isVerified: (json['is_verified'] as bool?) ?? false,
      );

  Map<String, dynamic> toUpsertJson() => {
        'profile_id': profileId,
        'expertise': expertise,
        'years_experience': yearsExperience,
        'bio': bio,
        'linkedin_url': linkedinUrl,
        'availability': availability,
        'profile_completion': profileCompletion,
      };

  MentorProfileModel copyWith({
    List<String>? expertise,
    int? yearsExperience,
    String? bio,
    String? linkedinUrl,
    String? availability,
    int? profileCompletion,
  }) =>
      MentorProfileModel(
        profileId: profileId,
        expertise: expertise ?? this.expertise,
        yearsExperience: yearsExperience ?? this.yearsExperience,
        bio: bio ?? this.bio,
        linkedinUrl: linkedinUrl ?? this.linkedinUrl,
        availability: availability ?? this.availability,
        profileCompletion: profileCompletion ?? this.profileCompletion,
        isVerified: isVerified,
      );

  static int calculateCompletion({
    List<String> expertise = const [],
    int? yearsExperience,
    String? bio,
    String? linkedinUrl,
    String? availability,
  }) {
    int total = 5;
    int filled = 0;

    if (expertise.isNotEmpty) filled++;
    if (yearsExperience != null) filled++;
    if (bio != null && bio.isNotEmpty) filled++;
    if (linkedinUrl != null && linkedinUrl.isNotEmpty) filled++;
    if (availability != null && availability.isNotEmpty) filled++;

    return (filled / total * 100).toInt();
  }

  static List<String> _toStrList(dynamic v) =>
      (v as List?)?.map((e) => e.toString()).toList() ?? [];
}
