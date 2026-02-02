import 'package:startlink/features/idea/domain/repositories/idea_activity_repository.dart';

class IdeaActivityLogger {
  final IdeaActivityRepository _repository;

  IdeaActivityLogger(this._repository);

  // Event Keys
  static const String ideaCreated = 'idea_created';
  static const String ideaPublished = 'idea_published';
  static const String mentorFeedbackAdded = 'mentor_feedback_added';
  static const String profileImproved = 'profile_improved';
  static const String confidenceIncreased = 'confidence_increased';
  static const String investorInterest = 'investor_interest';
  static const String collaborationStarted = 'collaboration_started';
  static const String ideaBoosted = 'idea_boosted';
  static const String milestoneAchieved = 'milestone_achieved';

  Future<void> logIdeaCreated(String ideaId, String title) async {
    await _repository.logActivity(
      ideaId: ideaId,
      eventType: ideaCreated,
      title: 'Idea Created',
      description: 'The idea "$title" was born.',
    );
  }

  Future<void> logIdeaPublished(String ideaId) async {
    await _repository.logActivity(
      ideaId: ideaId,
      eventType: ideaPublished,
      title: 'Idea Published',
      description: 'This idea is now visible to the community.',
    );
  }

  Future<void> logMentorFeedback(
    String ideaId,
    String mentorId,
    String mentorName,
    String feedbackPreview,
  ) async {
    await _repository.logActivity(
      ideaId: ideaId,
      eventType: mentorFeedbackAdded,
      title: 'Mentor Feedback Added',
      description:
          '"${feedbackPreview.length > 50 ? '${feedbackPreview.substring(0, 50)}...' : feedbackPreview}"',
      actorProfileId: mentorId,
      actorRole: 'Mentor',
      metadata: {'mentor_name': mentorName},
    );
  }

  Future<void> logConfidenceIncrease(
    String ideaId,
    double oldScore,
    double newScore,
  ) async {
    if (newScore <= oldScore) return;

    final delta = newScore - oldScore;
    await _repository.logActivity(
      ideaId: ideaId,
      eventType: confidenceIncreased,
      title: 'Confidence Increased',
      description:
          '+${delta.toStringAsFixed(1)}% improvement since last check.',
      metadata: {'old_score': oldScore, 'new_score': newScore, 'delta': delta},
    );
  }

  Future<void> logInvestorInterest(
    String ideaId,
    String investorId,
    String investorName,
  ) async {
    await _repository.logActivity(
      ideaId: ideaId,
      eventType: investorInterest,
      title: 'Investor Expressed Interest',
      description: '$investorName is interested in this idea.',
      actorProfileId: investorId,
      actorRole: 'Investor',
    );
  }

  Future<void> logCollaborationStarted(
    String ideaId,
    String collaboratorId,
    String role,
  ) async {
    await _repository.logActivity(
      ideaId: ideaId,
      eventType: collaborationStarted,
      title: 'Collaboration Started',
      description: 'A new $role has joined the team.',
      actorProfileId: collaboratorId,
      metadata: {'role': role},
    );
  }
}
