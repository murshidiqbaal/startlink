import 'package:startlink/features/profile/domain/entities/role_profile.dart';

/// Domain entity for the `collaborator_profiles` Supabase table.
class CollaboratorProfile extends RoleProfile {
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

  const CollaboratorProfile({
    required super.profileId,
    super.profileCompletion = 0,
    super.createdAt,
    super.updatedAt,
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
  }) : super(role: 'collaborator');

  @override
  List<Object?> get props => [
    ...super.props,
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
  ];
}
