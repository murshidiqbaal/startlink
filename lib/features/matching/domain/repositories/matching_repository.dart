import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/matching/domain/entities/idea_match.dart';

abstract class MatchingRepository {
  Future<List<IdeaMatch>> getMatchesForIdea(String ideaId);
  Future<void> generateMatchesForIdea(Idea idea);
}
