// lib/features/messaging/presentation/bloc/chat_state.dart

import '../../data/models/message_model.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final String ideaId;
  final String otherUserId;
  final String ideaTitle;
  final String otherUserName;

  /// True while a SendMessage request is in-flight
  final bool isSending;

  const ChatLoaded({
    required this.messages,
    required this.ideaId,
    required this.otherUserId,
    required this.ideaTitle,
    required this.otherUserName,
    this.isSending = false,
  });

  ChatLoaded copyWith({
    List<MessageModel>? messages,
    bool? isSending,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      ideaId: ideaId,
      otherUserId: otherUserId,
      ideaTitle: ideaTitle,
      otherUserName: otherUserName,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
}