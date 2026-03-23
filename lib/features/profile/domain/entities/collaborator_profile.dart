import 'package:equatable/equatable.dart';

class CollaboratorProfile extends Equatable {
  final String profileId;
  final List<String> specialties;
  final String? availability;
  final int? experienceYears;
  final List<String> preferredProjectTypes;
  final String? bio;
  final String? portfolioUrl;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? resumeUrl;
  final double? hourlyRate;
  final int profileCompletion;

  const CollaboratorProfile({
    required this.profileId,
    this.specialties = const [],
    this.availability,
    this.experienceYears,
    this.preferredProjectTypes = const [],
    this.bio,
    this.portfolioUrl,
    this.githubUrl,
    this.linkedinUrl,
    this.resumeUrl,
    this.hourlyRate,
    this.profileCompletion = 0,
  });

  @override
  List<Object?> get props => [
    profileId,
    specialties,
    availability,
    experienceYears,
    preferredProjectTypes,
    bio,
    portfolioUrl,
    githubUrl,
    linkedinUrl,
    resumeUrl,
    hourlyRate,
    profileCompletion,
  ];
}
