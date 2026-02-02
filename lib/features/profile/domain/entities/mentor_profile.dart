import 'package:equatable/equatable.dart';

class MentorProfile extends Equatable {
  final String profileId;
  final List<String> expertiseDomains;
  final int? yearsOfExperience;
  final String? mentorshipFocus;
  final String? linkedinUrl;
  final List<String> certifications;
  final int profileCompletion;
  final bool isVerified;

  const MentorProfile({
    required this.profileId,
    this.expertiseDomains = const [],
    this.yearsOfExperience,
    this.mentorshipFocus,
    this.linkedinUrl,
    this.certifications = const [],
    this.profileCompletion = 0,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    profileId,
    expertiseDomains,
    yearsOfExperience,
    mentorshipFocus,
    linkedinUrl,
    certifications,
    profileCompletion,
    isVerified,
  ];
}
