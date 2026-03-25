// lib/features/chat/presentation/bloc/chat_list_event.dart
import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadInnovatorChatRooms extends ChatListEvent {}

class LoadCollaboratorChatRooms extends ChatListEvent {}
