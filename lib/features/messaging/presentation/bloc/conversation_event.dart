// lib/features/messaging/presentation/bloc/conversation_event.dart

abstract class ConversationEvent {
  const ConversationEvent();
}

/// First load — shows a full-screen spinner
class LoadConversations extends ConversationEvent {
  const LoadConversations();
}

/// Pull-to-refresh — silently updates the list
class RefreshConversations extends ConversationEvent {
  const RefreshConversations();
}
