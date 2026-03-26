import '../../domain/entities/team.dart';

class TeamModel extends Team {
  const TeamModel({
    required super.id,
    required super.ideaId,
    required super.name,
    super.createdBy,
    required super.createdAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      ideaId: json['idea_id'] as String,
      name: json['name'] as String? ?? 'Idea Team',
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static List<TeamModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => TeamModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
