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
    on<SendMessage>(_onSendMessage);
    on<ReceiveRealtimeMessage>(_onReceiveMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());
    try {
      final messages = await _repository.getMessages(event.groupId);
      final teamMembers = await _repository.getTeamMembers(event.ideaId);
      emit(ChatRoomLoaded(
        groupId: event.groupId,
        messages: messages,
        teamMembers: teamMembers,
      ));

      // Subscribe to real-time updates for messages
      _channel?.unsubscribe();
      _channel = _supabase
          .channel('messages:${event.groupId}') // Use scoped channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'group_id',
              value: event.groupId,
            ),
            callback: (payload) {
              add(ReceiveRealtimeMessage(payload.newRecord));
            },
          )
          .subscribe();
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatRoomState> emit,
  ) async {
    try {
      final newMessage = await _repository.sendMessage(event.groupId, event.content);
      if (state is ChatRoomLoaded) {
        final current = state as ChatRoomLoaded;
        // Inject instantly instead of waiting for Realtime round-trip
        if (!current.messages.any((m) => m.id == newMessage.id)) {
          emit(ChatRoomLoaded(
            groupId: current.groupId,
            messages: [...current.messages, newMessage],
            teamMembers: current.teamMembers,
          ));
        }
      }
    } catch (e) {
      // Temporarily emit error so the user can see what's happening
      emit(ChatRoomError('Send failed: ${e.toString()}'));
    }
  }

  void _onReceiveMessage(
    ReceiveRealtimeMessage event,
    Emitter<ChatRoomState> emit,
  ) {
    if (state is ChatRoomLoaded) {
      final current = state as ChatRoomLoaded;
      
      // Filter by group_id
      if (event.payload['group_id'] != current.groupId) return;
      
      final newMessage = MessageModel.fromJson(event.payload);
      
      // Prevent duplicates if the message we sent also comes back via channel
      if (!current.messages.any((m) => m.id == newMessage.id)) {
        emit(ChatRoomLoaded(
          groupId: current.groupId,
          messages: [...current.messages, newMessage],
          teamMembers: current.teamMembers,
        ));
      }
    }
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
