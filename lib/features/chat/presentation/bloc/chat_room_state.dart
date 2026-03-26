import 'package:equatable/equatable.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_message.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final List<TeamMessage> messages;
  final List<TeamMember> teamMembers;

  const ChatRoomLoaded(this.messages, this.teamMembers);

  @override
  List<Object?> get props => [messages, teamMembers];
}

class ChatRoomError extends ChatRoomState {
  final String message;

  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}
