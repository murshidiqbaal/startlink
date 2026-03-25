// lib/features/chat/presentation/bloc/chat_list_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/chat_room.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<ChatRoom> rooms;
  const ChatListLoaded(this.rooms);

  @override
  List<Object?> get props => [rooms];
}

class ChatListError extends ChatListState {
  final String message;
  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
