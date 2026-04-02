import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/mentor_chat.dart';
import '../../../domain/repositories/mentor_chat_repository.dart';

// --- Events ---
abstract class MentorChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMentorChats extends MentorChatEvent {
  final String mentorId;
  LoadMentorChats(this.mentorId);
  @override
  List<Object?> get props => [mentorId];
}

class LoadMessages extends MentorChatEvent {
  final String chatId;
  LoadMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendMessage extends MentorChatEvent {
  final String chatId;
  final String senderId;
  final String content;
  SendMessage({required this.chatId, required this.senderId, required this.content});
  @override
  List<Object?> get props => [chatId, senderId, content];
}

class NewMessageReceived extends MentorChatEvent {
  final List<MentorMessage> messages;
  NewMessageReceived(this.messages);
  @override
  List<Object?> get props => [messages];
}

// --- States ---
abstract class MentorChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends MentorChatState {}
class ChatLoading extends MentorChatState {}
class ChatsLoaded extends MentorChatState {
  final List<MentorChat> chats;
  ChatsLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}
class MessagesLoaded extends MentorChatState {
  final List<MentorMessage> messages;
  MessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}
class ChatError extends MentorChatState {
  final String message;
  ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Bloc ---
class MentorChatBloc extends Bloc<MentorChatEvent, MentorChatState> {
  final IMentorChatRepository _repository;
  StreamSubscription? _messageSubscription;

  MentorChatBloc(this._repository) : super(ChatInitial()) {
    on<LoadMentorChats>(_onLoadMentorChats);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<NewMessageReceived>(_onNewMessageReceived);
  }

  Future<void> _onLoadMentorChats(LoadMentorChats event, Emitter<MentorChatState> emit) async {
    emit(ChatLoading());
    try {
      final chats = await _repository.getMentorChats(event.mentorId);
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<MentorChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getChatMessages(event.chatId);
      emit(MessagesLoaded(messages));
      
      await _messageSubscription?.cancel();
      _messageSubscription = _repository.subscribeToMessages(event.chatId).listen((messages) {
        add(NewMessageReceived(messages));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<MentorChatState> emit) async {
    try {
      await _repository.sendChatMessage(event.chatId, event.senderId, event.content);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onNewMessageReceived(NewMessageReceived event, Emitter<MentorChatState> emit) {
    emit(MessagesLoaded(event.messages));
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
