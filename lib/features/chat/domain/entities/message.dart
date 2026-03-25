import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String groupId;
  final String senderId;
  final String content;
  final bool isRead;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;

  const Message({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        senderId,
        content,
        isRead,
        createdAt,
        senderName,
        senderAvatar,
      ];
}
