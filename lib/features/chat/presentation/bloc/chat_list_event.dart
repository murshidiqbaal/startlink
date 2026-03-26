import 'package:equatable/equatable.dart';

abstract class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadInnovatorTeams extends ChatListEvent {}

class LoadCollaboratorTeams extends ChatListEvent {}
