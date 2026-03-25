import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String roomId;
  final String senderId;
  final String message;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.message,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, roomId, senderId, message, createdAt];
}
