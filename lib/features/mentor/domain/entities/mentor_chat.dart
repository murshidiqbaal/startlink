import 'package:equatable/equatable.dart';

class MentorChat extends Equatable {
  final String id;
  final String mentorId;
  final String userId;
  final String ideaId;
  final DateTime createdAt;
  final String? userName;
  final String? userAvatarUrl;
  final String? ideaTitle;
  final String? lastMessage;

  const MentorChat({
    required this.id,
    required this.mentorId,
    required this.userId,
    required this.ideaId,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
    this.ideaTitle,
    this.lastMessage,
  });

  @override
  List<Object?> get props => [
        id,
        mentorId,
        userId,
        ideaId,
        createdAt,
        userName,
        userAvatarUrl,
        ideaTitle,
        lastMessage,
      ];
}

class MentorMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatarUrl;

  const MentorMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        chatId,
        senderId,
        content,
        createdAt,
        senderName,
        senderAvatarUrl,
      ];
}
