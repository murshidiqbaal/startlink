import 'package:startlink/features/idea/domain/entities/idea.dart';

abstract class IdeaRepository {
  Future<List<Idea>> fetchMyIdeas();
}
