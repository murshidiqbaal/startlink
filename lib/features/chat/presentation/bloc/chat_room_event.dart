// lib/features/chat/presentation/bloc/chat_room_event.dart
import 'package:equatable/equatable.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatRoomEvent {
  final String ideaId;
  final String groupId;
  const LoadMessages(this.ideaId, this.groupId);

  @override
  List<Object?> get props => [ideaId, groupId];
}

class SendMessage extends ChatRoomEvent {
  final String groupId;
  final String content;
  const SendMessage(this.groupId, this.content);

  @override
  List<Object?> get props => [groupId, content];
}

class ReceiveRealtimeMessage extends ChatRoomEvent {
  final Map<String, dynamic> payload;
  const ReceiveRealtimeMessage(this.payload);

  @override
  List<Object?> get props => [payload];
}
