import 'package:equatable/equatable.dart';

enum MessageSender { user, ai }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isTyping; // For AI "thinking" state

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isTyping = false,
  });

  @override
  List<Object?> get props => [id, text, sender, timestamp, isTyping];
}
