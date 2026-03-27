import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class InvestorProfileState extends Equatable {
  const InvestorProfileState();

  @override
  List<Object?> get props => [];
}

class InvestorProfileInitial extends InvestorProfileState {}

class InvestorProfileLoading extends InvestorProfileState {}

class InvestorProfileLoaded extends InvestorProfileState {
  final ProfileModel baseProfile;
  final InvestorProfile profile;
  final UserVerification? verification;

  const InvestorProfileLoaded({
    required this.baseProfile,
    required this.profile,
    this.verification,
  });

  @override
  List<Object?> get props => [baseProfile, profile, verification];
}

class InvestorProfileSaving extends InvestorProfileState {}

class InvestorProfileSaved extends InvestorProfileState {}

class InvestorProfileError extends InvestorProfileState {
  final String message;
  const InvestorProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
