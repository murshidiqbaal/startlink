import 'package:startlink/features/idea/domain/entities/idea.dart';

class IdeaModel extends Idea {
  const IdeaModel({
    required super.id,
    required super.title,
    required super.description,
    required super.ownerId,
    required super.problemStatement,
    required super.targetMarket,
    required super.currentStage,
    super.isPublic,
    super.tags,
    super.status,
    super.viewCount,
    super.applicationCount,
    super.aiQualityScore,
    super.isVerified,
  });

  factory IdeaModel.fromJson(Map<String, dynamic> json) {
    return IdeaModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      ownerId: json['owner_id'] as String,
      problemStatement: json['problem_statement'] as String? ?? '',
      targetMarket: json['target_market'] as String? ?? '',
      currentStage: json['current_stage'] as String? ?? 'Idea',
      isPublic: json['visibility'] == 'Public', // Capitalized
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      status: json['status'] ?? 'Draft',
      viewCount: json['view_count'] ?? 0,
      applicationCount: json['application_count'] ?? 0,
      aiQualityScore: json['ai_quality_score'] != null
          ? (json['ai_quality_score'] as num).toDouble()
          : null,
      // Logic for reading verified status from joined profile would go here.
      // e.g. isVerified: json['profiles']?['user_verifications'] != null ? ...
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'owner_id': ownerId,
      'problem_statement': problemStatement,
      'target_market': targetMarket,
      'current_stage': currentStage,
      'visibility': isPublic ? 'Public' : 'Private', // Capitalized
      'tags': tags,
      'status': status,
      'ai_quality_score': aiQualityScore,
    };
  }
}
