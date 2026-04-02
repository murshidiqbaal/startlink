import '../../domain/entities/mentor_chat.dart';

class MentorChatModel extends MentorChat {
  const MentorChatModel({
    required super.id,
    required super.mentorId,
    required super.userId,
    required super.ideaId,
    required super.createdAt,
    super.userName,
    super.userAvatarUrl,
    super.ideaTitle,
    super.lastMessage,
  });

  factory MentorChatModel.fromJson(Map<String, dynamic> json) {
    final userProfile = json['user_profile'] as Map<String, dynamic>?;
    final idea = json['idea'] as Map<String, dynamic>?;

    return MentorChatModel(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      userId: json['user_id'] as String,
      ideaId: json['idea_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: userProfile?['full_name'] as String?,
      userAvatarUrl: userProfile?['avatar_url'] as String?,
      ideaTitle: idea?['title'] as String?,
      lastMessage: json['last_message'] as String?,
    );
  }
}

class MentorMessageModel extends MentorMessage {
  const MentorMessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.senderName,
    super.senderAvatarUrl,
  });

  factory MentorMessageModel.fromJson(Map<String, dynamic> json) {
    final senderProfile = json['sender_profile'] as Map<String, dynamic>?;

    return MentorMessageModel(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderName: senderProfile?['full_name'] as String?,
      senderAvatarUrl: senderProfile?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    };
  }
}
