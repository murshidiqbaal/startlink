import 'package:startlink/features/investor/domain/entities/investor_chat.dart';

class InvestorChatModel extends InvestorChat {
  const InvestorChatModel({
    required super.id,
    required super.ideaId,
    required super.investorId,
    required super.innovatorId,
    super.ideaTitle,
    super.innovatorName,
    super.innovatorAvatarUrl,
    super.investorName,
    super.investorAvatarUrl,
    required super.createdAt,
  });

  factory InvestorChatModel.fromJson(Map<String, dynamic> json) {
    return InvestorChatModel(
      id: json['id'],
      ideaId: json['idea_id'],
      investorId: json['investor_id'],
      innovatorId: json['innovator_id'],
      ideaTitle: json['idea']?['title'],
      innovatorName: json['innovator']?['full_name'],
      innovatorAvatarUrl: json['innovator']?['avatar_url'],
      investorName: json['investor']?['full_name'],
      investorAvatarUrl: json['investor']?['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idea_id': ideaId,
      'investor_id': investorId,
      'innovator_id': innovatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class InvestorMessageModel extends InvestorMessage {
  const InvestorMessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.content,
    required super.createdAt,
    super.senderName,
    super.senderAvatarUrl,
  });

  factory InvestorMessageModel.fromJson(Map<String, dynamic> json) {
    return InvestorMessageModel(
      id: json['id'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      senderName: json['sender']?['full_name'],
      senderAvatarUrl: json['sender']?['avatar_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
