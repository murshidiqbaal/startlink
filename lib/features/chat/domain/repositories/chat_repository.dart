import '../entities/team.dart';
import '../entities/team_member.dart';
import '../entities/team_message.dart';

abstract class ChatRepository {
  Future<List<Team>> getInnovatorTeams();
  Future<List<Team>> getCollaboratorTeams();
  Future<List<TeamMessage>> getTeamMessages(String teamId);
  Future<TeamMessage> sendTeamMessage(String teamId, String content);
  
  // Create or retrieve a team for an idea
  Future<String> getOrCreateTeam(String ideaId);
  Future<List<TeamMember>> getTeamMembers(String teamId);
  Stream<List<TeamMessage>> subscribeTeamMessages(String teamId);
  Future<bool> isTeamMember(String teamId, String userId);

  // Public Discussion (using groups/messages tables)
  Future<String> getOrCreatePublicGroup(String ideaId, String title);
  Future<List<TeamMessage>> getPublicMessages(String groupId);
  Future<TeamMessage> sendPublicMessage(String groupId, String content);
  Stream<List<TeamMessage>> subscribePublicMessages(String groupId);
}
