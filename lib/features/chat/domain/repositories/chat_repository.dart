import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';
import '../entities/chat_room.dart'; // This file now contains ChatGroup
import '../entities/message.dart';

abstract class ChatRepository {
  Future<List<ChatGroup>> getInnovatorGroups();
  Future<List<ChatGroup>> getCollaboratorGroups();
  Future<List<Message>> getMessages(String groupId);
  Future<Message> sendMessage(String groupId, String message);
  
  // Create or retrieve a group by type ('team' or 'public')
  Future<String> getOrCreateGroup(String ideaId, {String type = 'team'});
  Future<List<IdeaTeamMember>> getTeamMembers(String ideaId);
  Stream<List<Message>> subscribeMessages(String roomId);
  Future<bool> isTeamMember(String ideaId, String userId);
}
