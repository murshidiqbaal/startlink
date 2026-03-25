import 'package:equatable/equatable.dart';
import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';
import '../../domain/entities/message.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final String roomId;
  final List<Message> messages;
  final List<IdeaTeamMember> teamMembers;
  const ChatLoaded(this.roomId, this.messages, this.teamMembers);
  @override
  List<Object?> get props => [roomId, messages, teamMembers];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
