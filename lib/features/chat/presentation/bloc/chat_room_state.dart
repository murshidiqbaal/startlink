// lib/features/chat/presentation/bloc/chat_room_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/message.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<Message> messages;
  const ChatRoomLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class ChatRoomError extends ChatRoomState {
  final String message;
  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}
