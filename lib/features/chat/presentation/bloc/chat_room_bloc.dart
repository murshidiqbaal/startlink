import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_room_event.dart';
import 'chat_room_state.dart';

class ChatRoomBloc extends Bloc<ChatRoomEvent, ChatRoomState> {
  final ChatRepository _repository;
  StreamSubscription? _messageSubscription;

  ChatRoomBloc(this._repository) : super(ChatRoomInitial()) {
    // Supabase client can be used for direct presence or storage if needed
    on<LoadTeamMessages>(_onLoadMessages);
    on<SendTeamMessage>(_onSendMessage);
    on<ReceiveRealtimeMessage>(_onReceiveRealtime);
  }

  Future<void> _onLoadMessages(
    LoadTeamMessages event,
    Emitter<ChatRoomState> emit,
  ) async {
    emit(ChatRoomLoading());
    try {
      // Cancel previous subscription if any
      await _messageSubscription?.cancel();
      
      // Load initial messages and team members
      final results = await Future.wait([
        _repository.getTeamMessages(event.teamId),
        _repository.getTeamMembers(event.teamId),
      ]);
      
      final messages = results[0] as List<TeamMessage>;
      final members = results[1] as List<TeamMember>;
      
      emit(ChatRoomLoaded(messages, members));

      // Subscribe to real-time updates
      _messageSubscription = _repository.subscribeTeamMessages(event.teamId).listen(
        (updatedMessages) {
          add(ReceiveRealtimeMessage({'messages': updatedMessages}));
        },
      );
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendTeamMessage event,
    Emitter<ChatRoomState> emit,
  ) async {
    try {
      await _repository.sendTeamMessage(event.teamId, event.content);
    } catch (e) {
      emit(ChatRoomError(e.toString()));
    }
  }

  void _onReceiveRealtime(
    ReceiveRealtimeMessage event,
    Emitter<ChatRoomState> emit,
  ) {
    if (state is ChatRoomLoaded && event.payload.containsKey('messages')) {
      final currentMembers = (state as ChatRoomLoaded).teamMembers;
      final rawMessages = event.payload['messages'] as List<TeamMessage>;

      final enrichedMessages = rawMessages.map((msg) {
        // Find matching member for name/avatar
        final member = currentMembers.where((m) => m.userId == msg.senderId).firstOrNull;

        return msg.copyWith(
          senderName: member?.fullName,
          senderAvatar: member?.avatarUrl,
        );
      }).toList();

      emit(ChatRoomLoaded(enrichedMessages, currentMembers));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
