import 'package:equatable/equatable.dart';

class IdeaActivityLog extends Equatable {
  final String id;
  final String ideaId;
  final String? actorProfileId;
  final String? actorRole;
  final String eventType;
  final String title;
  final String? description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  const IdeaActivityLog({
    required this.id,
    required this.ideaId,
    this.actorProfileId,
    this.actorRole,
    required this.eventType,
    required this.title,
    this.description,
    this.metadata = const {},
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    ideaId,
    actorProfileId,
    actorRole,
    eventType,
    title,
    description,
    metadata,
    createdAt,
  ];
}
