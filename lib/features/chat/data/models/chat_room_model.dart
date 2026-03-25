// lib/features/chat/data/models/chat_room_model.dart
import '../../domain/entities/chat_room.dart';

class ChatGroupModel extends ChatGroup {
  const ChatGroupModel({
    required super.id,
    required super.ideaId,
    required super.name,
    required super.type,
  });

  factory ChatGroupModel.fromJson(Map<String, dynamic> json) {
    return ChatGroupModel(
      id: json['id'] as String,
      ideaId: json['idea_id'] as String,
      name: json['name'] as String? ?? 'Idea Team',
      type: json['type'] as String? ?? 'team',
    );
  }

  static List<ChatGroupModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => ChatGroupModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
