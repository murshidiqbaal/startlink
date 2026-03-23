// lib/features/messaging/presentation/bloc/conversation_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/messaging/data/repositories/message_repositoy.dart';

import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final MessageRepository _repository;

  ConversationBloc({MessageRepository? repository})
      : _repository = repository ?? MessageRepository(),
        super(const ConversationInitial()) {
    on<LoadConversations>(_onLoad);
    on<RefreshConversations>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(const ConversationLoading());
    await _fetch(emit);
  }

  Future<void> _onRefresh(
    RefreshConversations event,
    Emitter<ConversationState> emit,
  ) async {
    // Silent refresh — don't emit Loading, keep the existing list visible
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<ConversationState> emit) async {
    try {
      final conversations = await _repository.getConversations();
      emit(ConversationLoaded(conversations));
    } catch (e) {
      emit(ConversationError(e.toString()));
    }
  }
}