// lib/features/chat/presentation/bloc/chat_list_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _repository;

  ChatListBloc(this._repository) : super(ChatListInitial()) {
    on<LoadInnovatorChatRooms>(_onLoadInnovator);
    on<LoadCollaboratorChatRooms>(_onLoadCollaborator);
  }

  Future<void> _onLoadInnovator(
    LoadInnovatorChatRooms event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      final rooms = await _repository.getInnovatorChatRooms();
      emit(ChatListLoaded(rooms));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onLoadCollaborator(
    LoadCollaboratorChatRooms event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      final rooms = await _repository.getCollaboratorChatRooms();
      emit(ChatListLoaded(rooms));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
