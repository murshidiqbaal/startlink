// lib/features/chat/data/models/message_model.dart
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.roomId,
    required super.senderId,
    required super.message,
    required super.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      senderId: json['sender_id'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'room_id': roomId,
      'sender_id': senderId,
      'message': message,
    };
  }

  static List<MessageModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
