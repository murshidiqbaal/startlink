import 'package:startlink/features/profile/domain/entities/role_profile.dart';

/// Domain entity for the `mentor_profiles` Supabase table.
class MentorProfile extends RoleProfile {
  final List<String> expertise;
  final int? yearsExperience;
  final String? bio;
  final String? linkedinUrl;
  final String? availability;
  final bool isVerified;

  const MentorProfile({
    required super.profileId,
    super.profileCompletion = 0,
    super.createdAt,
    super.updatedAt,
    this.expertise = const [],
    this.yearsExperience,
    this.bio,
    this.linkedinUrl,
    this.availability,
    this.isVerified = false,
  }) : super(role: 'mentor');

  @override
  List<Object?> get props => [
        ...super.props,
        expertise,
        yearsExperience,
        bio,
        linkedinUrl,
        availability,
        isVerified,
      ];
}
