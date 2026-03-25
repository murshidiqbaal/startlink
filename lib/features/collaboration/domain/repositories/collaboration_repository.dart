import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';

abstract class CollaborationRepository {
  Future<void> applyForIdea({
    required String ideaId,
    required String innovatorId,
    required String roleApplied,
    required String message,
  });

  Future<List<CollaborationRequest>> getIdeaApplications(String ideaId);

  Future<void> updateApplicationStatus({
    required String requestId,
    required String status,
  });

  // Keep compatibility for existing BLoC logic if needed, 
  // but these should eventually be migrated to the new system.
  Future<List<CollaborationRequest>> fetchMyCollaborations();
  Future<List<CollaborationRequest>> fetchReceivedCollaborations();
  Future<List<IdeaTeamMember>> fetchIdeaTeamMembers(String ideaId);
}
