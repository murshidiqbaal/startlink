import 'dart:async';

import 'package:startlink/features/ai_co_founder/domain/entities/chat_message.dart';
import 'package:startlink/features/ai_co_founder/domain/entities/co_founder_response.dart';
import 'package:startlink/features/ai_co_founder/domain/repositories/co_founder_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoFounderRepositoryImpl implements CoFounderRepository {
  final SupabaseClient _supabase;
  final _controller = StreamController<ChatMessage>.broadcast();

  CoFounderRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Stream<ChatMessage> get messageStream => _controller.stream;

  @override
  Future<CoFounderResponse> sendMessage(
    String message, {
    String? contextId,
    List<ChatMessage>? history,
  }) async {
    try {
      // Serialize history for the edge function
      final historyJson = history
          ?.map(
            (msg) => {
              'role': msg.sender == MessageSender.user ? 'user' : 'ai',
              'text': msg.text,
            },
          )
          .toList();

      final response = await _supabase.functions.invoke(
        'ai-co-founder',
        body: {
          'message': message,
          'context_id': contextId,
          'mode': 'Strategic Advisor',
          'history': historyJson,
        },
      );

      if (response.status != 200) {
        throw Exception('AI Connect Error: ${response.status}');
      }

      final data = response.data as Map<String, dynamic>;

      // The edge function now returns a JSON object with reply, insights, etc.
      return CoFounderResponse.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  void dispose() {
    _controller.close();
  }
}
