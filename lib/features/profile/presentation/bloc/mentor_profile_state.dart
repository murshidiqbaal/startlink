import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class MentorProfileState extends Equatable {
  const MentorProfileState();

  @override
  List<Object?> get props => [];
}

class MentorProfileInitial extends MentorProfileState {}

class MentorProfileLoading extends MentorProfileState {}

class MentorProfileSaving extends MentorProfileState {}

class MentorProfileSaved extends MentorProfileState {}

class MentorProfileLoaded extends MentorProfileState {
  final ProfileModel baseProfile;
  final MentorProfile profile;
  final UserVerification? verification;

  const MentorProfileLoaded({
    required this.baseProfile,
    required this.profile,
    this.verification,
  });

  @override
  List<Object?> get props => [baseProfile, profile, verification];
}

class MentorProfileError extends MentorProfileState {
  final String message;
  const MentorProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
