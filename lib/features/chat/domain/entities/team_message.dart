import 'package:equatable/equatable.dart';

class TeamMessage extends Equatable {
  final String id;
  final String teamId;
  final String senderId;
  final String content;
  final DateTime createdAt;
  final String? senderName;
  final String? senderAvatar;

  const TeamMessage({
    required this.id,
    required this.teamId,
    required this.senderId,
    required this.content,
    required this.createdAt,
    this.senderName,
    this.senderAvatar,
  });

  TeamMessage copyWith({
    String? id,
    String? teamId,
    String? senderId,
    String? content,
    DateTime? createdAt,
    String? senderName,
    String? senderAvatar,
  }) {
    return TeamMessage(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
    );
  }

  @override
  List<Object?> get props => [
        id,
        teamId,
        senderId,
        content,
        createdAt,
        senderName,
        senderAvatar,
      ];
}
