import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/investor/domain/entities/investor_chat.dart';

abstract class InvestorCommunicationRepository {
  Future<List<Idea>> fetchIdeas();
  Future<List<Idea>> fetchRecommendedIdeas();
  Future<List<InvestorChat>> fetchChats(String investorId);
  Future<List<InvestorChat>> fetchChatsForInnovator(String innovatorId);
  Future<InvestorChat> getOrCreateChat({
    required String ideaId,
    required String investorId,
    required String innovatorId,
  });
  Future<List<InvestorMessage>> fetchMessages(String chatId);
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  });
  Future<InvestorMessage?> fetchLastMessage(String chatId);
  Stream<List<InvestorMessage>> watchMessages(String chatId);
}
