import 'package:startlink/features/ai_co_founder/domain/entities/chat_message.dart';

abstract class CoFounderRepository {
  Future<String> sendMessage(String message, {String? contextId});
  Stream<ChatMessage> get messageStream;
}
