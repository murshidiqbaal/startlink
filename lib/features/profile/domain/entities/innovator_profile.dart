import 'package:equatable/equatable.dart';

class InnovatorProfile extends Equatable {
  final String profileId;
  final List<String> skills;
  final String? experienceLevel;
  final String? education;
  final int profileCompletion;

  const InnovatorProfile({
    required this.profileId,
    this.skills = const [],
    this.experienceLevel,
    this.education,
    this.profileCompletion = 0,
  });

  @override
  List<Object?> get props => [
    profileId,
    skills,
    experienceLevel,
    education,
    profileCompletion,
  ];
}
