import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/investor/domain/repositories/investor_communication_repository.dart';

// Models
class InvestorChatItem extends Equatable {
  final String chatId;
  final String investorName;
  final String? avatarUrl;
  final String ideaTitle;
  final String lastMessage;
  final DateTime timestamp;

  const InvestorChatItem({
    required this.chatId,
    required this.investorName,
    this.avatarUrl,
    required this.ideaTitle,
    required this.lastMessage,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [chatId, investorName, avatarUrl, ideaTitle, lastMessage, timestamp];
}

// Events
abstract class InnovatorChatEvent extends Equatable {
  const InnovatorChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadInnovatorInvestorChats extends InnovatorChatEvent {
  final String innovatorId;
  const LoadInnovatorInvestorChats(this.innovatorId);
  @override
  List<Object?> get props => [innovatorId];
}

class RefreshInnovatorInvestorChats extends InnovatorChatEvent {
  final String innovatorId;
  const RefreshInnovatorInvestorChats(this.innovatorId);
  @override
  List<Object?> get props => [innovatorId];
}

// States
abstract class InnovatorChatState extends Equatable {
  const InnovatorChatState();
  @override
  List<Object?> get props => [];
}

class InnovatorChatsInitial extends InnovatorChatState {}
class InnovatorChatsLoading extends InnovatorChatState {}

class InnovatorChatsLoaded extends InnovatorChatState {
  final List<InvestorChatItem> investorChats;
  const InnovatorChatsLoaded(this.investorChats);
  @override
  List<Object?> get props => [investorChats];
}

class InnovatorChatsError extends InnovatorChatState {
  final String message;
  const InnovatorChatsError(this.message);
  @override
  List<Object?> get props => [message];
}

// BLoC
class InnovatorChatBloc extends Bloc<InnovatorChatEvent, InnovatorChatState> {
  final InvestorCommunicationRepository _repository;

  InnovatorChatBloc({required InvestorCommunicationRepository repository})
    : _repository = repository,
      super(InnovatorChatsInitial()) {
    on<LoadInnovatorInvestorChats>(_onLoadChats);
    on<RefreshInnovatorInvestorChats>(_onRefreshChats);
  }

  Future<void> _onLoadChats(
    LoadInnovatorInvestorChats event,
    Emitter<InnovatorChatState> emit,
  ) async {
    emit(InnovatorChatsLoading());
    try {
      final chats = await _repository.fetchChatsForInnovator(event.innovatorId);
      final List<InvestorChatItem> items = [];

      for (final chat in chats) {
        final lastMsg = await _repository.fetchLastMessage(chat.id);
        items.add(InvestorChatItem(
          chatId: chat.id,
          investorName: chat.investorName ?? 'Investor',
          avatarUrl: chat.investorAvatarUrl,
          ideaTitle: chat.ideaTitle ?? 'Investment Inquiry',
          lastMessage: lastMsg?.content ?? 'No messages yet',
          timestamp: lastMsg?.createdAt ?? chat.createdAt,
        ));
      }

      emit(InnovatorChatsLoaded(items));
    } catch (e) {
      emit(InnovatorChatsError(e.toString()));
    }
  }

  Future<void> _onRefreshChats(
    RefreshInnovatorInvestorChats event,
    Emitter<InnovatorChatState> emit,
  ) async {
    try {
      final chats = await _repository.fetchChatsForInnovator(event.innovatorId);
      final List<InvestorChatItem> items = [];

      for (final chat in chats) {
        final lastMsg = await _repository.fetchLastMessage(chat.id);
        items.add(InvestorChatItem(
          chatId: chat.id,
          investorName: chat.investorName ?? 'Investor',
          avatarUrl: chat.investorAvatarUrl,
          ideaTitle: chat.ideaTitle ?? 'Investment Inquiry',
          lastMessage: lastMsg?.content ?? 'No messages yet',
          timestamp: lastMsg?.createdAt ?? chat.createdAt,
        ));
      }

      emit(InnovatorChatsLoaded(items));
    } catch (e) {
      // Periodic refresh shouldn't necessarily block UI with error state if already loaded
    }
  }
}
