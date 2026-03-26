import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/team_message.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<TeamMessage>>? _messageSubscription;

  ChatBloc({required ChatRepository chatRepository})
      : _chatRepository = chatRepository,
        super(ChatInitial()) {
    on<LoadChatRoom>(_onLoadChatRoom);
    on<SendMessage>(_onSendMessage);
    on<ReceiveMessage>(_onReceiveMessage);
  }

  Future<void> _onLoadChatRoom(
    LoadChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final roomId = await _chatRepository.getOrCreateTeam(event.ideaId);
      final teamMembers = await _chatRepository.getTeamMembers(roomId);
      
      // Cancel previous subscription if any
      await _messageSubscription?.cancel();
      
      // Subscribe to real-time updates
      _messageSubscription = _chatRepository.subscribeTeamMessages(roomId).listen(
        (messages) {
          add(ReceiveMessage(messages));
        },
      );

      // Initial state with roomId and team members
      emit(ChatLoaded(roomId, const [], teamMembers));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      try {
        await _chatRepository.sendTeamMessage(currentState.roomId, event.text);
      } catch (e) {
        // Optionally emit error state or similar
      }
    }
  }

  void _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ChatState> emit,
  ) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;

      final enrichedMessages = event.messages.map((msg) {
        final member = currentState.teamMembers
            .where((m) => m.userId == msg.senderId)
            .firstOrNull;
        return msg.copyWith(
          senderName: member?.fullName,
          senderAvatar: member?.avatarUrl,
        );
      }).toList();

      emit(ChatLoaded(
          currentState.roomId, enrichedMessages, currentState.teamMembers));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
