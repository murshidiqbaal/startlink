import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/features/idea/data/models/idea_model.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/investor/data/models/investor_chat_model.dart';
import 'package:startlink/features/investor/domain/entities/investor_chat.dart';
import 'package:startlink/features/investor/domain/repositories/investor_repository.dart';

class InvestorRepositoryImpl implements InvestorRepository {
  final SupabaseClient _supabase;

  InvestorRepositoryImpl(this._supabase);

  @override
  Future<List<Idea>> fetchIdeas() async {
    final response = await _supabase
        .from('ideas')
        .select('*, profiles(full_name, avatar_url)')
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => IdeaModel.fromJson(json)).toList();
  }

  @override
  Future<List<Idea>> fetchRecommendedIdeas() async {
    // Basic recommendation logic: sort by view_count or specific criteria
    final response = await _supabase
        .from('ideas')
        .select('*, profiles(full_name, avatar_url)')
        .order('view_count', ascending: false)
        .limit(10);
    
    return (response as List).map((json) => IdeaModel.fromJson(json)).toList();
  }

  @override
  Future<List<InvestorChat>> fetchChats(String investorId) async {
    final response = await _supabase
        .from('investor_chats')
        .select('''
          *,
          idea:ideas(title),
          innovator:profiles(full_name)
        ''')
        .eq('investor_id', investorId)
        .order('created_at', ascending: false);
    
    return (response as List).map((json) => InvestorChatModel.fromJson(json)).toList();
  }

  @override
  Future<InvestorChat> getOrCreateChat({
    required String ideaId,
    required String investorId,
    required String innovatorId,
  }) async {
    final response = await _supabase
        .from('investor_chats')
        .upsert({
          'idea_id': ideaId,
          'investor_id': investorId,
          'innovator_id': innovatorId,
        })
        .select('''
          *,
          idea:ideas(title),
          innovator:profiles(full_name)
        ''')
        .single();
    
    return InvestorChatModel.fromJson(response);
  }

  @override
  Future<List<InvestorMessage>> fetchMessages(String chatId) async {
    final response = await _supabase
        .from('investor_messages')
        .select('''
          *,
          sender:profiles(full_name, avatar_url)
        ''')
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
    
    return (response as List).map((json) => InvestorMessageModel.fromJson(json)).toList();
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    await _supabase.from('investor_messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    });
  }

  @override
  Stream<List<InvestorMessage>> watchMessages(String chatId) {
    // Real-time subscription for messages
    return _supabase
        .from('investor_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .asyncMap((event) async {
          // Since stream doesn't support complex joins easily, we might need to fetch profile info separately or use a view
          // For simplicity in this demo, we'll re-fetch or assume minimal info
          return fetchMessages(chatId);
        });
  }
}
