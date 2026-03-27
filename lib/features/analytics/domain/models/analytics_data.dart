import 'package:equatable/equatable.dart';
import 'idea_performance.dart';

class AnalyticsData extends Equatable {
  final int totalIdeas;
  final int totalRequests;
  final int totalCollaborators;
  final int investorInterest;
  final int totalMessages;
  final int activeIdeas;
  final List<IdeaPerformance> topIdeas;

  const AnalyticsData({
    required this.totalIdeas,
    required this.totalRequests,
    required this.totalCollaborators,
    required this.investorInterest,
    required this.totalMessages,
    required this.activeIdeas,
    required this.topIdeas,
  });

  @override
  List<Object?> get props => [
    totalIdeas,
    totalRequests,
    totalCollaborators,
    investorInterest,
    totalMessages,
    activeIdeas,
    topIdeas,
  ];

  static const empty = AnalyticsData(
    totalIdeas: 0,
    totalRequests: 0,
    totalCollaborators: 0,
    investorInterest: 0,
    totalMessages: 0,
    activeIdeas: 0,
    topIdeas: [],
  );
}
