// lib/features/chat/data/models/message_model.dart
import '../../domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required super.id,
    required super.groupId,
    required super.senderId,
    required super.content,
    required super.isRead,
    required super.createdAt,
    super.senderName,
    super.senderAvatar,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final profile = (json['sender'] ?? json['profiles']) as Map<String, dynamic>?;
    
    return MessageModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: profile?['full_name'] as String?,
      senderAvatar: profile?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'sender_id': senderId,
      'content': content,
      'is_read': isRead,
    };
  }

  static List<MessageModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
