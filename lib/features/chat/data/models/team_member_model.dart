import '../../domain/entities/team_member.dart';

class TeamMemberModel extends TeamMember {
  const TeamMemberModel({
    required super.id,
    required super.teamId,
    required super.userId,
    required super.role,
    required super.joinedAt,
    super.fullName,
    super.avatarUrl,
  });

  factory TeamMemberModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] ?? json['user'];
    return TeamMemberModel(
      id: json['id'] as String,
      teamId: json['team_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'member',
      joinedAt: DateTime.parse(json['joined_at'] as String),
      fullName: profile != null ? profile['full_name'] as String? : null,
      avatarUrl: profile != null ? profile['avatar_url'] as String? : null,
    );
  }

  static List<TeamMemberModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => TeamMemberModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
