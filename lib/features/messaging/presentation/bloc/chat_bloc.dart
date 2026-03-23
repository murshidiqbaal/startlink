// lib/features/messaging/presentation/bloc/chat_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/messaging/data/repositories/message_repositoy.dart';

import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final MessageRepository _repository;

  StreamSubscription? _messagesSub;

  // Stored so _MessagesUpdated can build ChatLoaded without repeating them
  String? _ideaId;
  String? _otherUserId;
  String? _ideaTitle;
  String? _otherUserName;

  ChatBloc({MessageRepository? repository})
      : _repository = repository ?? MessageRepository(),
        super(const ChatInitial()) {
    on<OpenChat>(_onOpen);
    on<SendMessage>(_onSend);
    on<MessagesUpdated>(_onUpdated);
  }

  Future<void> _onOpen(OpenChat event, Emitter<ChatState> emit) async {
    emit(const ChatLoading());

    // Cache conversation context for later events
    _ideaId = event.ideaId;
    _otherUserId = event.otherUserId;
    _ideaTitle = event.ideaTitle;
    _otherUserName = event.otherUserName;

    // Cancel any previous subscription (e.g. if re-used for different chat)
    await _messagesSub?.cancel();

    // Subscribe to the realtime message stream; each emission triggers
    // _MessagesUpdated which rebuilds the ChatLoaded state
    _messagesSub = _repository
        .watchMessages(
          ideaId: event.ideaId,
          otherUserId: event.otherUserId,
        )
        .listen(
          (msgs) => add(MessagesUpdated(msgs)),
          onError: (e) => emit(ChatError(e.toString())),
        );

    // Mark any unread messages from the other user as read immediately
    _repository
        .markAsRead(ideaId: event.ideaId, otherUserId: event.otherUserId)
        .ignore();
  }

  void _onUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    // Guard against unlikely case where context isn't set yet
    if (_ideaId == null) return;

    final isSending =
        state is ChatLoaded ? (state as ChatLoaded).isSending : false;

    emit(ChatLoaded(
      messages: event.messages,
      ideaId: _ideaId!,
      otherUserId: _otherUserId!,
      ideaTitle: _ideaTitle!,
      otherUserName: _otherUserName!,
      isSending: isSending,
    ));
  }

  Future<void> _onSend(SendMessage event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;
    final current = state as ChatLoaded;

    if (event.content.trim().isEmpty) return;

    // Show a sending indicator
    emit(current.copyWith(isSending: true));

    try {
      await _repository.sendMessage(
        ideaId: _ideaId!,
        receiverId: _otherUserId!,
        content: event.content,
      );
      // The realtime subscription will push the new message automatically;
      // just clear the sending flag
      emit(current.copyWith(isSending: false));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _messagesSub?.cancel();
    return super.close();
  }
}