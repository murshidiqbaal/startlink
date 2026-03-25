import 'package:startlink/features/profile/domain/entities/role_profile.dart';

/// Domain entity for the `investor_profiles` Supabase table.
class InvestorProfile extends RoleProfile {
  final String? investmentFocus;
  final double? ticketSizeMin;
  final double? ticketSizeMax;
  final String? preferredStage;
  final String? organizationName;
  final String? linkedinUrl;
  final String? bio;
  final bool isVerified;

  const InvestorProfile({
    required super.profileId,
    super.profileCompletion = 0,
    super.createdAt,
    super.updatedAt,
    this.investmentFocus,
    this.ticketSizeMin,
    this.ticketSizeMax,
    this.preferredStage,
    this.organizationName,
    this.linkedinUrl,
    this.bio,
    this.isVerified = false,
  }) : super(role: 'investor');

  @override
  List<Object?> get props => [
    ...super.props,
    investmentFocus,
    ticketSizeMin,
    ticketSizeMax,
    preferredStage,
    organizationName,
    linkedinUrl,
    bio,
    isVerified,
  ];
}
