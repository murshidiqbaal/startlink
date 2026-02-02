import 'package:equatable/equatable.dart';

class CompassRecommendation extends Equatable {
  final String id;
  final String profileId;
  final String role;
  final String actionKey;
  final String title;
  final String description;
  final Map<String, dynamic> expectedBenefit;
  final int priority;

  const CompassRecommendation({
    required this.id,
    required this.profileId,
    required this.role,
    required this.actionKey,
    required this.title,
    required this.description,
    required this.expectedBenefit,
    required this.priority,
  });

  @override
  List<Object?> get props => [
    id,
    profileId,
    role,
    actionKey,
    title,
    description,
    expectedBenefit,
    priority,
  ];
}
