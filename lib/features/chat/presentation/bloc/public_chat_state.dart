import 'package:equatable/equatable.dart';
import '../../domain/entities/team_message.dart';

abstract class PublicChatState extends Equatable {
  const PublicChatState();

  @override
  List<Object?> get props => [];
}

class PublicChatInitial extends PublicChatState {}

class PublicChatLoading extends PublicChatState {}

class PublicChatLoaded extends PublicChatState {
  final List<TeamMessage> messages;
  final bool isSending;

  const PublicChatLoaded(this.messages, {this.isSending = false});

  @override
  List<Object?> get props => [messages, isSending];
}

class PublicChatError extends PublicChatState {
  final String message;
  const PublicChatError(this.message);

  @override
  List<Object?> get props => [message];
}
