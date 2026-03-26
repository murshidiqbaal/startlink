import '../../domain/entities/team_message.dart';

class TeamMessageModel extends TeamMessage {
  const TeamMessageModel({
    required super.id,
    required super.teamId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.senderName,
    super.senderAvatar,
  });

  factory TeamMessageModel.fromJson(Map<String, dynamic> json) {
    final profile = json['sender'] ?? json['profiles'];
    return TeamMessageModel(
      id: json['id'] as String,
      teamId: (json['team_id'] ?? json['group_id']) as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: profile != null ? profile['full_name'] as String? : null,
      senderAvatar: profile != null ? profile['avatar_url'] as String? : null,
    );
  }

  static List<TeamMessageModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => TeamMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'team_id': teamId,
      'sender_id': senderId,
      'content': content,
    };
  }
}
