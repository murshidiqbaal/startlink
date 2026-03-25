// lib/features/chat/presentation/bloc/chat_room_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/message_model.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatRepository _repository;
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;

  ChatRoomBloc(this._repository, this._supabase) : super(ChatRoomInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());
    try {
      final messages = await _repository.getMessages(event.roomId);
      emit(ChatRoomLoaded(messages));

      // Subscribe to real-time updates for this room
      _channel?.unsubscribe();
      _channel = _supabase
          .channel('room_${event.roomId}')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'room_id',
              value: event.roomId,
            ),
            callback: (payload) {
              add(ReceiveMessage(payload.newRecord));
            },
          )
          .subscribe();
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatRoomState> emit,
  ) async {
    try {
      await _repository.sendMessage(event.roomId, event.content);
    } catch (e) {
      // In a real app, we might want a separate error state or toast
    }
  }

  void _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ChatRoomState> emit,
  ) {
    if (state is ChatRoomLoaded) {
      final current = state as ChatRoomLoaded;
      final newMessage = MessageModel.fromJson(event.payload);
      
      // Prevent duplicates if the message we sent also comes back via channel
      if (!current.messages.any((m) => m.id == newMessage.id)) {
        emit(ChatRoomLoaded([...current.messages, newMessage]));
      }
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
