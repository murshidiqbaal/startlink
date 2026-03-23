import 'package:startlink/features/ai_co_founder/domain/entities/chat_message.dart';
import 'package:startlink/features/ai_co_founder/domain/entities/co_founder_response.dart';

abstract class CoFounderRepository {
  Future<CoFounderResponse> sendMessage(
    String message, {
    String? contextId,
    List<ChatMessage>? history,
  });
  Stream<ChatMessage> get messageStream;
}
