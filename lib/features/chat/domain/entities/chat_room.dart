// lib/features/chat/domain/entities/chat_room.dart
import 'package:equatable/equatable.dart';

class ChatGroup extends Equatable {
  final String id;
  final String ideaId;
  final String name;
  final String type; // 'team' or 'public'

  const ChatGroup({
    required this.id,
    required this.ideaId,
    required this.name,
    required this.type,
  });

  @override
  List<Object?> get props => [id, ideaId, name, type];
}
