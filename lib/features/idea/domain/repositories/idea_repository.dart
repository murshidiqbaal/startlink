import 'package:startlink/features/idea/domain/entities/idea.dart';

abstract class IdeaRepository {
  Future<List<Idea>> fetchMyIdeas();
  Future<List<Idea>> fetchAllPublicIdeas();
  Future<String> createIdea(Idea idea);
  Future<void> updateIdea(Idea idea);
  Future<void> incrementViewCount(String ideaId);
  Future<List<Idea>> fetchPublishedIdeas();
}
