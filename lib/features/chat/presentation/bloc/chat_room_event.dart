import 'package:equatable/equatable.dart';

abstract class ChatRoomEvent extends Equatable {
  const ChatRoomEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeamMessages extends ChatRoomEvent {
  final String teamId;
  const LoadTeamMessages(this.teamId);

  @override
  List<Object?> get props => [teamId];
}

class SendTeamMessage extends ChatRoomEvent {
  final String teamId;
  final String content;
  const SendTeamMessage(this.teamId, this.content);

  @override
  List<Object?> get props => [teamId, content];
}

class ReceiveRealtimeMessage extends ChatRoomEvent {
  final Map<String, dynamic> payload;
  const ReceiveRealtimeMessage(this.payload);

  @override
  List<Object?> get props => [payload];
}
