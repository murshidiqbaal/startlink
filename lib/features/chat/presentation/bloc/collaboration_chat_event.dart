import 'package:equatable/equatable.dart';

abstract class CollaborationChatEvent extends Equatable {
  const CollaborationChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadInnovatorChats extends CollaborationChatEvent {}

class LoadCollaboratorChats extends CollaborationChatEvent {}
