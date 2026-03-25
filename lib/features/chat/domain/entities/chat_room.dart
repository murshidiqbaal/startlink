// lib/features/chat/domain/entities/chat_room.dart
class ChatRoom {
  final String id;
  final String ideaId;
  final String ideaTitle;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.ideaId,
    required this.ideaTitle,
    required this.createdAt,
  });
}
