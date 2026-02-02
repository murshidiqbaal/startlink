import 'package:startlink/features/profile/domain/entities/investor_profile.dart';

class InvestorProfileModel extends InvestorProfile {
  const InvestorProfileModel({
    required super.profileId,
    super.investmentFocus,
    super.ticketSizeMin,
    super.ticketSizeMax,
    super.preferredStage,
    super.organizationName,
    super.linkedinUrl,
    super.profileCompletion,
    super.isVerified,
  });

  factory InvestorProfileModel.fromJson(Map<String, dynamic> json) {
    return InvestorProfileModel(
      profileId: json['profile_id'] as String,
      investmentFocus: json['investment_focus'] as String?,
      ticketSizeMin: (json['ticket_size_min'] as num?)?.toDouble(),
      ticketSizeMax: (json['ticket_size_max'] as num?)?.toDouble(),
      preferredStage: json['preferred_stage'] as String?,
      organizationName: json['organization_name'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      profileCompletion: json['profile_completion'] ?? 0,
      isVerified: json['is_verified'] ?? false,
    );
  }

  factory InvestorProfileModel.fromEntity(InvestorProfile entity) {
    return InvestorProfileModel(
      profileId: entity.profileId,
      investmentFocus: entity.investmentFocus,
      ticketSizeMin: entity.ticketSizeMin,
      ticketSizeMax: entity.ticketSizeMax,
      preferredStage: entity.preferredStage,
      organizationName: entity.organizationName,
      linkedinUrl: entity.linkedinUrl,
      profileCompletion: entity.profileCompletion,
      isVerified: entity.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'investment_focus': investmentFocus,
      'ticket_size_min': ticketSizeMin,
      'ticket_size_max': ticketSizeMax,
      'preferred_stage': preferredStage,
      'organization_name': organizationName,
      'linkedin_url': linkedinUrl,
      'profile_completion': profileCompletion,
      'is_verified': isVerified,
    };
  }

  InvestorProfileModel copyWith({
    String? investmentFocus,
    double? ticketSizeMin,
    double? ticketSizeMax,
    String? preferredStage,
    String? organizationName,
    String? linkedinUrl,
    int? profileCompletion,
    bool? isVerified,
  }) {
    return InvestorProfileModel(
      profileId: profileId,
      investmentFocus: investmentFocus ?? this.investmentFocus,
      ticketSizeMin: ticketSizeMin ?? this.ticketSizeMin,
      ticketSizeMax: ticketSizeMax ?? this.ticketSizeMax,
      preferredStage: preferredStage ?? this.preferredStage,
      organizationName: organizationName ?? this.organizationName,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      profileCompletion: profileCompletion ?? this.profileCompletion,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
