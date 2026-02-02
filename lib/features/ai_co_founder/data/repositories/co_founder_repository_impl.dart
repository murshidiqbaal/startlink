import 'dart:async';

import 'package:startlink/features/ai_co_founder/domain/entities/chat_message.dart';
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
  Future<String> sendMessage(String message, {String? contextId}) async {
    try {
      // 1. Call Edge Function
      // We assume an edge function 'ai-co-founder' exists
      final response = await _supabase.functions.invoke(
        'ai-co-founder',
        body: {
          'message': message,
          'context_id': contextId, // Could be idea_id
          'mode': 'skeptical_co_founder', // Persona
        },
      );

      if (response.status != 200) {
        throw Exception('AI Connect Error: ${response.status}');
      }

      final data = response.data;
      final replyText = data['reply'] as String;

      return replyText;
    } catch (e) {
      throw Exception('Failed to get AI response: $e');
    }
  }

  void dispose() {
    _controller.close();
  }
}
