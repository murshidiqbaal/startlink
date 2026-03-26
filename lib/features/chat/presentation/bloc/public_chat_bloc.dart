import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'public_chat_event.dart';
import 'public_chat_state.dart';

class PublicChatBloc extends Bloc<PublicChatEvent, PublicChatState> {
  final ChatRepository _repository;
  StreamSubscription? _messageSubscription;

  PublicChatBloc(this._repository) : super(PublicChatInitial()) {
    on<LoadPublicMessages>(_onLoadMessages);
    on<SendPublicMessage>(_onSendMessage);
    on<ReceivePublicRealtimeMessage>(_onReceiveRealtime);
  }

  Future<void> _onLoadMessages(
    LoadPublicMessages event,
    Emitter<PublicChatState> emit,
  ) async {
    emit(PublicChatLoading());
    try {
      await _messageSubscription?.cancel();
      
      final messages = await _repository.getPublicMessages(event.groupId);
      emit(PublicChatLoaded(messages));

      _messageSubscription = _repository.subscribePublicMessages(event.groupId).listen(
        (updatedMessages) {
          add(ReceivePublicRealtimeMessage(updatedMessages));
        },
      );
    } catch (e) {
      emit(PublicChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendPublicMessage event,
    Emitter<PublicChatState> emit,
  ) async {
    if (state is PublicChatLoaded) {
      final currentState = state as PublicChatLoaded;
      emit(PublicChatLoaded(currentState.messages, isSending: true));
      try {
        await _repository.sendPublicMessage(event.groupId, event.content);
        // Real-time subscription will handle the update
        emit(PublicChatLoaded(currentState.messages, isSending: false));
      } catch (e) {
        emit(PublicChatError(e.toString()));
      }
    }
  }

  void _onReceiveRealtime(
    ReceivePublicRealtimeMessage event,
    Emitter<PublicChatState> emit,
  ) {
    if (state is PublicChatLoaded) {
      emit(PublicChatLoaded(event.messages));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
