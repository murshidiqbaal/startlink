import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_list_event.dart';
import 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatRepository _repository;

  ChatListBloc(this._repository) : super(ChatListInitial()) {
    on<LoadInnovatorTeams>(_onLoadInnovator);
    on<LoadCollaboratorTeams>(_onLoadCollaborator);
  }

  Future<void> _onLoadInnovator(
    LoadInnovatorTeams event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      final teams = await _repository.getInnovatorTeams();
      emit(ChatListLoaded(teams));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onLoadCollaborator(
    LoadCollaboratorTeams event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      final teams = await _repository.getCollaboratorTeams();
      emit(ChatListLoaded(teams));
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
