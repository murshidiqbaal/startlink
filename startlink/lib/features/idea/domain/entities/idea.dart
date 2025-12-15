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

  const Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    this.tags = const [],
    this.status = 'Draft',
    this.aiQualityScore,
    this.aiSummary,
    this.aiSuggestedCollaborators,
  });

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ownerId: json['owner_id'],
      tags: List<String>.from(json['tags'] ?? []),
      status: json['status'] ?? 'Draft',
      aiQualityScore: json['ai_quality_score']?.toDouble(),
      aiSummary: json['ai_summary'],
      aiSuggestedCollaborators: json['ai_suggested_collaborators'] != null
          ? List<String>.from(json['ai_suggested_collaborators'])
          : null,
    );
  }
}
