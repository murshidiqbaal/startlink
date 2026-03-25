import '../entities/collaboration_chat.dart';

abstract class CollaborationChatRepository {
  Future<List<CollaborationChat>> loadInnovatorChats();
  Future<List<CollaborationChat>> loadCollaboratorChats();
}
