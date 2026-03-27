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
    super.bio,
    super.profileCompletion = 0,
    super.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory InvestorProfileModel.fromEntity(InvestorProfile entity) {
    return InvestorProfileModel(
      profileId: entity.profileId,
      investmentFocus: entity.investmentFocus,
      ticketSizeMin: entity.ticketSizeMin,
      ticketSizeMax: entity.ticketSizeMax,
      preferredStage: entity.preferredStage,
      organizationName: entity.organizationName,
      linkedinUrl: entity.linkedinUrl,
      bio: entity.bio,
      profileCompletion: entity.profileCompletion,
      isVerified: entity.isVerified,
    );
  }

  factory InvestorProfileModel.fromJson(Map<String, dynamic> json) =>
      InvestorProfileModel(
        profileId: json['profile_id'] as String,
        investmentFocus: json['investment_focus'] as String?,
        ticketSizeMin: (json['ticket_size_min'] as num?)?.toDouble(),
        ticketSizeMax: (json['ticket_size_max'] as num?)?.toDouble(),
        preferredStage: json['preferred_stage'] as String?,
        organizationName: json['organization_name'] as String?,
        linkedinUrl: json['linkedin_url'] as String?,
        bio: json['bio'] as String?,
        profileCompletion: (json['profile_completion'] as num?)?.toInt() ?? 0,
        isVerified: (json['is_verified'] as bool?) ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      );

  Map<String, dynamic> toUpsertJson() => {
    'profile_id': profileId,
    'investment_focus': investmentFocus,
    'ticket_size_min': ticketSizeMin,
    'ticket_size_max': ticketSizeMax,
    'preferred_stage': preferredStage,
    'organization_name': organizationName,
    'linkedin_url': linkedinUrl,
    'profile_completion': profileCompletion,
  };

  static int calculateCompletion({
    String? investmentFocus,
    double? ticketSizeMin,
    double? ticketSizeMax,
    String? preferredStage,
    String? organizationName,
    String? linkedinUrl,
  }) {
    const int totalFields = 6;
    int filledFields = 0;

    if (organizationName != null && organizationName.isNotEmpty) filledFields++;
    if (investmentFocus != null && investmentFocus.isNotEmpty) filledFields++;
    if (ticketSizeMin != null) filledFields++;
    if (ticketSizeMax != null) filledFields++;
    if (preferredStage != null && preferredStage.isNotEmpty) filledFields++;
    if (linkedinUrl != null && linkedinUrl.isNotEmpty) filledFields++;

    return ((filledFields / totalFields) * 100).toInt();
  }

  InvestorProfileModel copyWith({
    String? investmentFocus,
    double? ticketSizeMin,
    double? ticketSizeMax,
    String? preferredStage,
    String? organizationName,
    String? linkedinUrl,
    int? profileCompletion,
  }) => InvestorProfileModel(
    profileId: profileId,
    investmentFocus: investmentFocus ?? this.investmentFocus,
    ticketSizeMin: ticketSizeMin ?? this.ticketSizeMin,
    ticketSizeMax: ticketSizeMax ?? this.ticketSizeMax,
    preferredStage: preferredStage ?? this.preferredStage,
    organizationName: organizationName ?? this.organizationName,
    linkedinUrl: linkedinUrl ?? this.linkedinUrl,
    bio: bio ?? this.bio,
    profileCompletion: profileCompletion ?? this.profileCompletion,
    isVerified: isVerified,
  );
}
