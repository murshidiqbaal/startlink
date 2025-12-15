import 'package:startlink/features/collaboration/domain/entities/collaboration.dart';

abstract class CollaborationRepository {
  Future<void> applyForCollaboration({
    required String ideaId,
    required String innovatorId,
    required String roleApplied,
    required String message,
  });

  Future<List<Collaboration>> fetchMyCollaborations(); // For Collaborators

  Future<List<Collaboration>> fetchCollaborationsForIdea(
    String ideaId,
  ); // For Innovators

  Future<void> updateCollaborationStatus({
    required String collaborationId,
    required String status,
  });

  Future<List<Collaboration>>
  fetchReceivedCollaborations(); // For Innovators to see all applications
}
