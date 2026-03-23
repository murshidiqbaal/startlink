import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/profile/domain/entities/user_profile.dart';

abstract class AdminRepository {
  Future<List<UserProfile>> getAllUsers();
  Future<void> banUser(String userId);
  Future<void> unbanUser(String userId);

  Future<List<Idea>> getAllIdeas();
  Future<void> deleteIdea(String ideaId);
  Future<void> flagIdea(String ideaId);
}
