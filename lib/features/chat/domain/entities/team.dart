import 'package:equatable/equatable.dart';

class Team extends Equatable {
  final String id;
  final String ideaId;
  final String name;
  final String? createdBy;
  final DateTime createdAt;

  const Team({
    required this.id,
    required this.ideaId,
    required this.name,
    this.createdBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, ideaId, name, createdBy, createdAt];
}
