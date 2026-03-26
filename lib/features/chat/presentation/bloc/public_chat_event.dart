import 'package:equatable/equatable.dart';
import '../../domain/entities/team_message.dart';

abstract class PublicChatEvent extends Equatable {
  const PublicChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadPublicMessages extends PublicChatEvent {
  final String groupId;
  const LoadPublicMessages(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class SendPublicMessage extends PublicChatEvent {
  final String groupId;
  final String content;
  const SendPublicMessage(this.groupId, this.content);

  @override
  List<Object?> get props => [groupId, content];
}

class ReceivePublicRealtimeMessage extends PublicChatEvent {
  final List<TeamMessage> messages;
  const ReceivePublicRealtimeMessage(this.messages);

  @override
  List<Object?> get props => [messages];
}
