import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/collaboration_chat_repository.dart';
import 'collaboration_chat_event.dart';
import 'collaboration_chat_state.dart';

class CollaborationChatBloc extends Bloc<CollaborationChatEvent, CollaborationChatState> {
  final CollaborationChatRepository _chatRepository;

  CollaborationChatBloc(this._chatRepository) : super(CollaborationChatInitial()) {
    on<LoadInnovatorChats>(_onLoadInnovatorChats);
    on<LoadCollaboratorChats>(_onLoadCollaboratorChats);
  }

  Future<void> _onLoadInnovatorChats(
    LoadInnovatorChats event,
    Emitter<CollaborationChatState> emit,
  ) async {
    emit(CollaborationChatLoading());
    try {
      final chats = await _chatRepository.loadInnovatorChats();
      emit(CollaborationChatLoaded(chats));
    } catch (e) {
      emit(CollaborationChatError('Failed to load innovator chats: $e'));
    }
  }

  Future<void> _onLoadCollaboratorChats(
    LoadCollaboratorChats event,
    Emitter<CollaborationChatState> emit,
  ) async {
    emit(CollaborationChatLoading());
    try {
      final chats = await _chatRepository.loadCollaboratorChats();
      emit(CollaborationChatLoaded(chats));
    } catch (e) {
      emit(CollaborationChatError('Failed to load collaborator chats: $e'));
    }
  }
}
