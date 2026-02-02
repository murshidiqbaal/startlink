import 'package:startlink/features/compass/domain/entities/compass_recommendation.dart';

class CompassRecommendationModel extends CompassRecommendation {
  const CompassRecommendationModel({
    required super.id,
    required super.profileId,
    required super.role,
    required super.actionKey,
    required super.title,
    required super.description,
    required super.expectedBenefit,
    required super.priority,
  });

  factory CompassRecommendationModel.fromJson(Map<String, dynamic> json) {
    return CompassRecommendationModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      role: json['role'] as String,
      actionKey: json['action_key'] as String,
      title: json['title'] as String,
      description: json['description'] ?? '',
      expectedBenefit: json['expected_benefit'] as Map<String, dynamic>? ?? {},
      priority: json['priority'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile_id': profileId,
      'role': role,
      'action_key': actionKey,
      'title': title,
      'description': description,
      'expected_benefit': expectedBenefit,
      'priority': priority,
    };
  }
}
