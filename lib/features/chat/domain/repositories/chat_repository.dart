// lib/features/chat/domain/repositories/chat_repository.dart
import '../entities/chat_room.dart';
import '../entities/message.dart';

abstract class ChatRepository {
  Future<List<ChatRoom>> getInnovatorChatRooms();
  Future<List<ChatRoom>> getCollaboratorChatRooms();
  Future<List<Message>> getMessages(String roomId);
  Future<void> sendMessage(String roomId, String message);
  
  // Existing ChatBloc requirements
  Future<String> getOrCreateRoom(String ideaId);
  Future<List<Map<String, dynamic>>> getTeamMembers(String ideaId);
  Stream<List<Message>> subscribeMessages(String roomId);
  Future<bool> isTeamMember(String ideaId, String userId);
}
