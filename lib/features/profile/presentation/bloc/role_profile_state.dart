// lib/features/profile/presentation/bloc/role_profile_state.dart
//
// Non-generic state for RoleProfileBloc.
// `profile` is typed as the abstract `RoleProfile` — UI uses `is` runtime
// checks (e.g. `if (state.profile is InvestorProfile)`) to access role fields.
// This completely eliminates the generic type-mismatch crashes.

import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';

// Re-export so existing imports keep working
export 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart'
    show VerificationStatus;

abstract class RoleProfileState extends Equatable {
  const RoleProfileState();

  @override
  List<Object?> get props => [];
}

class RoleProfileInitial extends RoleProfileState {}

class RoleProfileLoading extends RoleProfileState {}

abstract class RoleProfileLoaded extends RoleProfileState {
  final ProfileModel baseProfile;
  final RoleProfile roleProfile;
  final int completionScore;
  final VerificationStatus verificationStatus;

  const RoleProfileLoaded({
    required this.baseProfile,
    required this.roleProfile,
    required this.completionScore,
    required this.verificationStatus,
  });

  @override
  List<Object?> get props => [
        baseProfile,
        roleProfile,
        completionScore,
        verificationStatus,
      ];
}

class InvestorProfileLoaded extends RoleProfileLoaded {
  final InvestorProfile investorProfile;

  InvestorProfileLoaded({
    required super.baseProfile,
    required this.investorProfile,
    required super.completionScore,
    required super.verificationStatus,
  }) : super(roleProfile: investorProfile);

  @override
  List<Object?> get props => [...super.props, investorProfile];

  InvestorProfileLoaded copyWith({
    ProfileModel? baseProfile,
    InvestorProfile? investorProfile,
    int? completionScore,
    VerificationStatus? verificationStatus,
  }) {
    return InvestorProfileLoaded(
      baseProfile: baseProfile ?? this.baseProfile,
      investorProfile: investorProfile ?? this.investorProfile,
      completionScore: completionScore ?? this.completionScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

class MentorProfileLoaded extends RoleProfileLoaded {
  final MentorProfile mentorProfile;

  MentorProfileLoaded({
    required super.baseProfile,
    required this.mentorProfile,
    required super.completionScore,
    required super.verificationStatus,
  }) : super(roleProfile: mentorProfile);

  @override
  List<Object?> get props => [...super.props, mentorProfile];

  MentorProfileLoaded copyWith({
    ProfileModel? baseProfile,
    MentorProfile? mentorProfile,
    int? completionScore,
    VerificationStatus? verificationStatus,
  }) {
    return MentorProfileLoaded(
      baseProfile: baseProfile ?? this.baseProfile,
      mentorProfile: mentorProfile ?? this.mentorProfile,
      completionScore: completionScore ?? this.completionScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

class InnovatorProfileLoaded extends RoleProfileLoaded {
  final InnovatorProfile innovatorProfile;

  InnovatorProfileLoaded({
    required super.baseProfile,
    required this.innovatorProfile,
    required super.completionScore,
    required super.verificationStatus,
  }) : super(roleProfile: innovatorProfile);

  @override
  List<Object?> get props => [...super.props, innovatorProfile];

  InnovatorProfileLoaded copyWith({
    ProfileModel? baseProfile,
    InnovatorProfile? innovatorProfile,
    int? completionScore,
    VerificationStatus? verificationStatus,
  }) {
    return InnovatorProfileLoaded(
      baseProfile: baseProfile ?? this.baseProfile,
      innovatorProfile: innovatorProfile ?? this.innovatorProfile,
      completionScore: completionScore ?? this.completionScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

class CollaboratorProfileLoaded extends RoleProfileLoaded {
  final CollaboratorProfile collaboratorProfile;

  CollaboratorProfileLoaded({
    required super.baseProfile,
    required this.collaboratorProfile,
    required super.completionScore,
    required super.verificationStatus,
  }) : super(roleProfile: collaboratorProfile);

  @override
  List<Object?> get props => [...super.props, collaboratorProfile];

  CollaboratorProfileLoaded copyWith({
    ProfileModel? baseProfile,
    CollaboratorProfile? collaboratorProfile,
    int? completionScore,
    VerificationStatus? verificationStatus,
  }) {
    return CollaboratorProfileLoaded(
      baseProfile: baseProfile ?? this.baseProfile,
      collaboratorProfile: collaboratorProfile ?? this.collaboratorProfile,
      completionScore: completionScore ?? this.completionScore,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}

class RoleProfileSaving extends RoleProfileState {}

class RoleProfileSaved extends RoleProfileState {}

class RoleProfileError extends RoleProfileState {
  final String message;

  const RoleProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
