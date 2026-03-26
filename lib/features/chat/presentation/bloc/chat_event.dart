import 'package:equatable/equatable.dart';

import '../../domain/entities/team_message.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadChatRoom extends ChatEvent {
  final String ideaId;
  const LoadChatRoom(this.ideaId);
  @override
  List<Object?> get props => [ideaId];
}

class SendMessage extends ChatEvent {
  final String text;
  const SendMessage(this.text);
  @override
  List<Object?> get props => [text];
}

class ReceiveMessage extends ChatEvent {
  final List<TeamMessage> messages;
  const ReceiveMessage(this.messages);
  @override
  List<Object?> get props => [messages];
}
