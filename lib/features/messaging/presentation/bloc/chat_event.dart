// lib/features/messaging/presentation/bloc/chat_event.dart

import '../../data/models/message_model.dart';

abstract class ChatEvent {
  const ChatEvent();
}

/// Open a conversation — triggers initial fetch + realtime subscription
class OpenChat extends ChatEvent {
  final String ideaId;
  final String otherUserId;
  final String ideaTitle;
  final String otherUserName;

  const OpenChat({
    required this.ideaId,
    required this.otherUserId,
    required this.ideaTitle,
    required this.otherUserName,
  });
}

/// User hits Send
class SendMessage extends ChatEvent {
  final String content;

  const SendMessage(this.content);
}

class MessagesUpdated extends ChatEvent {
  final List<MessageModel> messages;

  const MessagesUpdated(this.messages);
}
