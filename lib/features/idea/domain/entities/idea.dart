class Idea {
  final String id;
  final String title;
  final String description;
  final String ownerId;
  final List<String> tags;
  final String status; // 'Draft', 'Published', 'Funded'

  // AI Metrics (Future Use)
  final double? aiQualityScore; // 0.0 to 1.0
  final String? aiSummary;
  final List<String>? aiSuggestedCollaborators;

  final String problemStatement;
  final String targetMarket;
  final String currentStage; // Idea, Prototype, MVP, Scaling
  final bool isPublic;
  final int viewCount;
  final int applicationCount;

  final bool isVerified;
  final String? ownerName;
  final String? ownerAvatarUrl;
  final String? industry;
  final String? subIndustry;
  final String? businessModel;
  final String? monetizationStrategy;
  final String? location;
  final double? fundingNeeded;
  final double? equityOffered;
  final int teamSize;
  final bool lookingForInvestor;
  final bool lookingForCofounder;
  final bool lookingForMentor;
  final String? coverImageUrl;
  final String? pitchDeckUrl;
  final String? demoVideoUrl;
  final String? websiteUrl;

  const Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.problemStatement,
    required this.targetMarket,
    required this.currentStage,
    this.isPublic = true,
    this.tags = const [],
    this.status = 'Draft',
    this.viewCount = 0,
    this.applicationCount = 0,
    this.aiQualityScore,
    this.aiSummary,
    this.aiSuggestedCollaborators,
    this.isVerified = false,
    this.ownerName,
    this.ownerAvatarUrl,
    this.industry,
    this.subIndustry,
    this.businessModel,
    this.monetizationStrategy,
    this.location,
    this.fundingNeeded,
    this.equityOffered,
    this.teamSize = 1,
    this.lookingForInvestor = false,
    this.lookingForCofounder = false,
    this.lookingForMentor = false,
    this.coverImageUrl,
    this.pitchDeckUrl,
    this.demoVideoUrl,
    this.websiteUrl,
  });

  Idea copyWithVerification(bool isVerified) {
    return Idea(
      id: id,
      title: title,
      description: description,
      ownerId: ownerId,
      problemStatement: problemStatement,
      targetMarket: targetMarket,
      currentStage: currentStage,
      isPublic: isPublic,
      tags: tags,
      status: status,
      viewCount: viewCount,
      applicationCount: applicationCount,
      aiQualityScore: aiQualityScore,
      aiSummary: aiSummary,
      aiSuggestedCollaborators: aiSuggestedCollaborators,
      isVerified: isVerified,
      ownerName: ownerName,
      ownerAvatarUrl: ownerAvatarUrl,
      industry: industry,
      subIndustry: subIndustry,
      businessModel: businessModel,
      monetizationStrategy: monetizationStrategy,
      location: location,
      fundingNeeded: fundingNeeded,
      equityOffered: equityOffered,
      teamSize: teamSize,
      lookingForInvestor: lookingForInvestor,
      lookingForCofounder: lookingForCofounder,
      lookingForMentor: lookingForMentor,
      coverImageUrl: coverImageUrl,
      pitchDeckUrl: pitchDeckUrl,
      demoVideoUrl: demoVideoUrl,
      websiteUrl: websiteUrl,
    );
  }

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ownerId: json['owner_id'],
      problemStatement: json['problem_statement'] ?? '',
      targetMarket: json['target_market'] ?? '',
      currentStage: json['current_stage'] ?? 'Idea',
      isPublic: json['visibility'] == 'Public',
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] ?? 'Draft',
      viewCount: json['view_count'] ?? 0,
      applicationCount: json['application_count'] ?? 0,
      aiQualityScore: (json['ai_quality_score'] as num?)?.toDouble(),
      aiSummary: json['ai_summary'],
      aiSuggestedCollaborators: json['ai_suggested_collaborators'] != null
          ? List<String>.from(json['ai_suggested_collaborators'])
          : null,
      isVerified: json['is_verified'] ?? false,
      ownerName: json['profiles']?['full_name'],
      ownerAvatarUrl: json['profiles']?['avatar_url'],
      industry: json['industry'],
      subIndustry: json['sub_industry'],
      businessModel: json['business_model'],
      monetizationStrategy: json['monetization_strategy'],
      location: json['location'],
      fundingNeeded: (json['funding_needed'] as num?)?.toDouble(),
      equityOffered: (json['equity_offered'] as num?)?.toDouble(),
      teamSize: json['team_size'] ?? 1,
      lookingForInvestor: json['looking_for_investor'] ?? false,
      lookingForCofounder: json['looking_for_cofounder'] ?? false,
      lookingForMentor: json['looking_for_mentor'] ?? false,
      coverImageUrl: json['cover_image_url'],
      pitchDeckUrl: json['pitch_deck_url'],
      demoVideoUrl: json['demo_video_url'],
      websiteUrl: json['website_url'],
    );
  }
}
