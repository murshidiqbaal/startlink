import '../entities/mentor_chat.dart';

abstract class IMentorChatRepository {
  Future<List<MentorChat>> getMentorChats(String mentorId);
  Future<List<MentorMessage>> getChatMessages(String chatId);
  Future<void> sendChatMessage(String chatId, String senderId, String content);
  Stream<List<MentorMessage>> subscribeToMessages(String chatId);
  Future<MentorChat> createOrFetchChat(String mentorId, String userId, String ideaId);
}
