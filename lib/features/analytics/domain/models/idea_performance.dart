import 'package:equatable/equatable.dart';

class IdeaPerformance extends Equatable {
  final String id;
  final String title;
  final int collaboratorsCount;
  final int requestsCount;
  final int messagesCount;

  const IdeaPerformance({
    required this.id,
    required this.title,
    required this.collaboratorsCount,
    required this.requestsCount,
    required this.messagesCount,
  });

  @override
  List<Object?> get props => [id, title, collaboratorsCount, requestsCount, messagesCount];

  factory IdeaPerformance.fromJson(Map<String, dynamic> json) {
    return IdeaPerformance(
      id: json['id'] as String,
      title: json['title'] as String,
      collaboratorsCount: json['collaborators'] as int? ?? 0,
      requestsCount: json['requests'] as int? ?? 0,
      messagesCount: json['messages'] as int? ?? 0,
    );
  }
}
