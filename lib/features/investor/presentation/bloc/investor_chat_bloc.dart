import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/investor/domain/entities/investor_chat.dart';
import 'package:startlink/features/investor/domain/repositories/investor_communication_repository.dart';

// Events
abstract class InvestorChatEvent extends Equatable {
  const InvestorChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadInvestorChats extends InvestorChatEvent {
  final String investorId;
  const LoadInvestorChats(this.investorId);
  @override
  List<Object?> get props => [investorId];
}

class LoadChatMessages extends InvestorChatEvent {
  final String chatId;
  const LoadChatMessages(this.chatId);
  @override
  List<Object?> get props => [chatId];
}

class SendInvestorMessage extends InvestorChatEvent {
  final String chatId;
  final String senderId;
  final String content;
  const SendInvestorMessage({
    required this.chatId,
    required this.senderId,
    required this.content,
  });
  @override
  List<Object?> get props => [chatId, senderId, content];
}

class ConnectWithInnovator extends InvestorChatEvent {
  final String ideaId;
  final String investorId;
  final String innovatorId;
  const ConnectWithInnovator({
    required this.ideaId,
    required this.investorId,
    required this.innovatorId,
  });
  @override
  List<Object?> get props => [ideaId, investorId, innovatorId];
}

// States
abstract class InvestorChatState extends Equatable {
  const InvestorChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends InvestorChatState {}
class ChatLoading extends InvestorChatState {}

class ChatsLoaded extends InvestorChatState {
  final List<InvestorChat> chats;
  const ChatsLoaded(this.chats);
  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends InvestorChatState {
  final List<InvestorMessage> messages;
  final String chatId;
  const MessagesLoaded(this.messages, this.chatId);
  @override
  List<Object?> get props => [messages, chatId];
}

class ChatConnectionSuccess extends InvestorChatState {
  final InvestorChat chat;
  const ChatConnectionSuccess(this.chat);
  @override
  List<Object?> get props => [chat];
}

class ChatError extends InvestorChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}

class InvestorChatBloc extends Bloc<InvestorChatEvent, InvestorChatState> {
  final InvestorCommunicationRepository _repository;
  StreamSubscription? _messageSubscription;

  InvestorChatBloc({required InvestorCommunicationRepository repository})
    : _repository = repository,
      super(ChatInitial()) {
    on<LoadInvestorChats>(_onLoadChats);
    on<LoadChatMessages>(_onLoadMessages);
    on<SendInvestorMessage>(_onSendMessage);
    on<ConnectWithInnovator>(_onConnect);
    on<_UpdateMessagesLocally>(_onUpdateMessagesLocally);
  }

  Future<void> _onLoadChats(
    LoadInvestorChats event,
    Emitter<InvestorChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chats = await _repository.fetchChats(event.investorId);
      emit(ChatsLoaded(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadChatMessages event,
    Emitter<InvestorChatState> emit,
  ) async {
    emit(ChatLoading());
    await _messageSubscription?.cancel();
    
    // Initial fetch
    try {
      final messages = await _repository.fetchMessages(event.chatId);
      emit(MessagesLoaded(messages, event.chatId));

      // Real-time subscription
      _messageSubscription = _repository.watchMessages(event.chatId).listen((messages) {
        add(_UpdateMessagesLocally(messages, event.chatId));
      });
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onUpdateMessagesLocally(_UpdateMessagesLocally event, Emitter<InvestorChatState> emit) {
    emit(MessagesLoaded(event.messages, event.chatId));
  }

  Future<void> _onSendMessage(
    SendInvestorMessage event,
    Emitter<InvestorChatState> emit,
  ) async {
    try {
      await _repository.sendMessage(
        chatId: event.chatId,
        senderId: event.senderId,
        content: event.content,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onConnect(
    ConnectWithInnovator event,
    Emitter<InvestorChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      final chat = await _repository.getOrCreateChat(
        ideaId: event.ideaId,
        investorId: event.investorId,
        innovatorId: event.innovatorId,
      );
      emit(ChatConnectionSuccess(chat));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}

class _UpdateMessagesLocally extends InvestorChatEvent {
  final List<InvestorMessage> messages;
  final String chatId;
  const _UpdateMessagesLocally(this.messages, this.chatId);
  @override
  List<Object?> get props => [messages, chatId];
}
