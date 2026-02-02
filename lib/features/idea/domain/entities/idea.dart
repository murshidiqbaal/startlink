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
  });

  final bool isVerified;

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
      isPublic: json['visibility'] == 'public',
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] ?? 'Draft',
      viewCount: json['view_count'] ?? 0,
      applicationCount: json['application_count'] ?? 0,
      aiQualityScore: json['ai_quality_score']?.toDouble(),
      aiSummary: json['ai_summary'],
      aiSuggestedCollaborators: json['ai_suggested_collaborators'] != null
          ? List<String>.from(json['ai_suggested_collaborators'])
          : null,
    );
  }
}
