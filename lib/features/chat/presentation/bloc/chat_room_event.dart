// lib/features/chat/presentation/bloc/chat_room_event.dart
import 'package:equatable/equatable.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatRoomEvent {
  final String roomId;
  const LoadMessages(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

class SendMessageEvent extends ChatRoomEvent {
  final String roomId;
  final String content;
  const SendMessageEvent(this.roomId, this.content);

  @override
  List<Object?> get props => [roomId, content];
}

class ReceiveMessage extends ChatRoomEvent {
  final Map<String, dynamic> payload;
  const ReceiveMessage(this.payload);

  @override
  List<Object?> get props => [payload];
}
