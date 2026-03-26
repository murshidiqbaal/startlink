import 'package:equatable/equatable.dart';
import '../../domain/entities/team.dart';

abstract class ChatListState extends Equatable {
  const ChatListState();

  @override
  List<Object?> get props => [];
}

class ChatListInitial extends ChatListState {}

class ChatListLoading extends ChatListState {}

class ChatListLoaded extends ChatListState {
  final List<Team> teams;

  const ChatListLoaded(this.teams);

  @override
  List<Object?> get props => [teams];
}

class ChatListError extends ChatListState {
  final String message;

  const ChatListError(this.message);

  @override
  List<Object?> get props => [message];
}
