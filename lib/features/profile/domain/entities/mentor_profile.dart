import 'package:startlink/features/profile/domain/entities/role_profile.dart';

/// Domain entity for the `mentor_profiles` Supabase table.
class MentorProfile extends RoleProfile {
  final List<String> expertiseDomains;
  final int? yearsOfExperience;
  final String? mentorshipFocus;
  final String? linkedinUrl;
  final List<String> certifications;
  final bool isVerified;

  const MentorProfile({
    required super.profileId,
    super.profileCompletion = 0,
    super.createdAt,
    super.updatedAt,
    this.expertiseDomains = const [],
    this.yearsOfExperience,
    this.mentorshipFocus,
    this.linkedinUrl,
    this.certifications = const [],
    this.isVerified = false,
  }) : super(role: 'mentor');

  @override
  List<Object?> get props => [
    ...super.props,
    expertiseDomains,
    yearsOfExperience,
    mentorshipFocus,
    linkedinUrl,
    certifications,
    isVerified,
  ];
}
