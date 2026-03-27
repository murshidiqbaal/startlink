import 'package:equatable/equatable.dart';

class InvestorChat extends Equatable {
  final String id;
  final String ideaId;
  final String investorId;
  final String innovatorId;
  final String? ideaTitle;
  final String? innovatorName;
  final String? innovatorAvatarUrl;
  final String? investorName;
  final String? investorAvatarUrl;
  final DateTime createdAt;

  const InvestorChat({
    required this.id,
    required this.ideaId,
    required this.investorId,
    required this.innovatorId,
    this.ideaTitle,
    this.innovatorName,
    this.innovatorAvatarUrl,
    this.investorName,
    this.investorAvatarUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        ideaId,
        investorId,
        innovatorId,
        ideaTitle,
        innovatorName,
        innovatorAvatarUrl,
        investorName,
        investorAvatarUrl,
        createdAt,
      ];
}

class InvestorMessage extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatarUrl;

  const InvestorMessage({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatarUrl,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, content, createdAt, senderName, senderAvatarUrl];
}
