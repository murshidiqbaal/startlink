import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';

abstract class InvestorProfileEvent extends Equatable {
  const InvestorProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadInvestorProfile extends InvestorProfileEvent {
  final String userId;
  const LoadInvestorProfile(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateInvestorProfile extends InvestorProfileEvent {
  final InvestorProfile profile;
  const UpdateInvestorProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SubmitInvestorProfile extends InvestorProfileEvent {
  final InvestorProfile profile;
  const SubmitInvestorProfile(this.profile);

  @override
  List<Object?> get props => [profile];
}

class SubmitVerification extends InvestorProfileEvent {
  final String userId;
  const SubmitVerification(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateConsolidatedProfile extends InvestorProfileEvent {
  final ProfileModel baseProfile;
  final InvestorProfile investorProfile;
  
  const UpdateConsolidatedProfile({
    required this.baseProfile,
    required this.investorProfile,
  });

  @override
  List<Object?> get props => [baseProfile, investorProfile];
}
