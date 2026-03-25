import 'package:equatable/equatable.dart';
import '../../domain/entities/collaboration_chat.dart';

abstract class CollaborationChatState extends Equatable {
  const CollaborationChatState();

  @override
  List<Object?> get props => [];
}

class CollaborationChatInitial extends CollaborationChatState {}

class CollaborationChatLoading extends CollaborationChatState {}

class CollaborationChatLoaded extends CollaborationChatState {
  final List<CollaborationChat> chats;

  const CollaborationChatLoaded(this.chats);

  @override
  List<Object?> get props => [chats];
}

class CollaborationChatError extends CollaborationChatState {
  final String message;

  const CollaborationChatError(this.message);

  @override
  List<Object?> get props => [message];
}
