// lib/features/messaging/presentation/bloc/conversation_state.dart

import '../../data/models/conversation_model.dart';

abstract class ConversationState {
  const ConversationState();
}

class ConversationInitial extends ConversationState {
  const ConversationInitial();
}

/// Shown only on the first load, not on refresh
class ConversationLoading extends ConversationState {
  const ConversationLoading();
}

class ConversationLoaded extends ConversationState {
  final List<ConversationModel> conversations;
  const ConversationLoaded(this.conversations);
}

class ConversationError extends ConversationState {
  final String message;
  const ConversationError(this.message);
}
