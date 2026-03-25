// lib/features/chat/presentation/bloc/chat_room_state.dart
import 'package:equatable/equatable.dart';
import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';
import '../../domain/entities/message.dart';

abstract class ChatRoomState extends Equatable {
  const ChatRoomState();

  @override
  List<Object?> get props => [];
}

class ChatRoomInitial extends ChatRoomState {}

class ChatRoomLoading extends ChatRoomState {}

class ChatRoomLoaded extends ChatRoomState {
  final String groupId;
  final List<Message> messages;
  final List<IdeaTeamMember> teamMembers;
  
  const ChatRoomLoaded({
    required this.groupId,
    required this.messages,
    required this.teamMembers,
  });

  @override
  List<Object?> get props => [groupId, messages, teamMembers];
}

class ChatRoomError extends ChatRoomState {
  final String message;
  const ChatRoomError(this.message);

  @override
  List<Object?> get props => [message];
}
