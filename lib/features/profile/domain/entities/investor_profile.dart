import 'package:equatable/equatable.dart';

class InvestorProfile extends Equatable {
  final String profileId;
  final String? investmentFocus;
  final double? ticketSizeMin;
  final double? ticketSizeMax;
  final String? preferredStage;
  final String? organizationName;
  final String? linkedinUrl;
  final int profileCompletion;
  final bool isVerified;

  const InvestorProfile({
    required this.profileId,
    this.investmentFocus,
    this.ticketSizeMin,
    this.ticketSizeMax,
    this.preferredStage,
    this.organizationName,
    this.linkedinUrl,
    this.profileCompletion = 0,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    profileId,
    investmentFocus,
    ticketSizeMin,
    ticketSizeMax,
    preferredStage,
    organizationName,
    linkedinUrl,
    profileCompletion,
    isVerified,
  ];
}
