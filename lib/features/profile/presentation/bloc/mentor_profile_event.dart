import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';

abstract class MentorProfileEvent extends Equatable {
  const MentorProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadMentorProfile extends MentorProfileEvent {
  final String userId;
  const LoadMentorProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateMentorProfile extends MentorProfileEvent {
  final MentorProfile profile;
  const UpdateMentorProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SubmitMentorProfile extends MentorProfileEvent {
  final MentorProfile profile;
  const SubmitMentorProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SubmitVerification extends MentorProfileEvent {
  final String userId;
  const SubmitVerification(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateConsolidatedProfile extends MentorProfileEvent {
  final ProfileModel baseProfile;
  final MentorProfile mentorProfile;

  const UpdateConsolidatedProfile({
    required this.baseProfile,
    required this.mentorProfile,
  });

  @override
  List<Object?> get props => [baseProfile, mentorProfile];
}
