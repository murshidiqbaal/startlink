// lib/features/chat/data/models/chat_room_model.dart
import '../../domain/entities/chat_room.dart';

class ChatRoomModel extends ChatRoom {
  ChatRoomModel({
    required super.id,
    required super.ideaId,
    required super.ideaTitle,
    required super.createdAt,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      ideaId: json['idea_id'] as String,
      ideaTitle: json['ideas'] != null ? json['ideas']['title'] as String : 'Unknown Idea',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static List<ChatRoomModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => ChatRoomModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
