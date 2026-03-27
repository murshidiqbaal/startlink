import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/data/models/idea_model.dart';
import 'package:startlink/features/investor/domain/entities/investor_chat.dart';
import 'package:startlink/features/investor/data/models/investor_chat_model.dart';
import 'package:startlink/features/investor/domain/repositories/investor_communication_repository.dart';

class InvestorCommunicationRepositoryImpl implements InvestorCommunicationRepository {
  final SupabaseClient _supabase;

  InvestorCommunicationRepositoryImpl(this._supabase);

  @override
  Future<List<Idea>> fetchIdeas() async {
    final response = await _supabase
        .from('ideas')
        .select('*, profiles(full_name, avatar_url)')
        .eq('status', 'Published')
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
  }

  @override
  Future<List<Idea>> fetchRecommendedIdeas() async {
    final response = await _supabase
        .from('ideas')
        .select('*, profiles(full_name, avatar_url)')
        .eq('status', 'Published')
        .limit(10);
    
    return (response as List).map((e) => IdeaModel.fromJson(e)).toList();
  }

  @override
  Future<List<InvestorChat>> fetchChats(String investorId) async {
    final response = await _supabase
        .from('investor_chats')
        .select('''
          *,
          idea:ideas(title),
          innovator:profiles!investor_chats_innovator_id_fkey(full_name, avatar_url),
          investor:profiles!investor_chats_investor_id_fkey(full_name, avatar_url)
        ''')
        .eq('investor_id', investorId);
    
    return (response as List).map((e) => InvestorChatModel.fromJson(e)).toList();
  }

  @override
  Future<List<InvestorChat>> fetchChatsForInnovator(String innovatorId) async {
    final response = await _supabase
        .from('investor_chats')
        .select('''
          *,
          idea:ideas(title),
          innovator:profiles!investor_chats_innovator_id_fkey(full_name, avatar_url),
          investor:profiles!investor_chats_investor_id_fkey(full_name, avatar_url)
        ''')
        .eq('innovator_id', innovatorId)
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => InvestorChatModel.fromJson(e)).toList();
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
        }, onConflict: 'idea_id, investor_id')
        .select('''
          *,
          idea:ideas(title),
          innovator:profiles!investor_chats_innovator_id_fkey(full_name, avatar_url),
          investor:profiles!investor_chats_investor_id_fkey(full_name, avatar_url)
        ''')
        .single();
    
    return InvestorChatModel.fromJson(response);
  }

  @override
  Future<List<InvestorMessage>> fetchMessages(String chatId) async {
    final response = await _supabase
        .from('investor_messages')
        .select('*, sender:profiles(full_name, avatar_url)')
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);
    
    return (response as List).map((e) => InvestorMessageModel.fromJson(e)).toList();
  }

  @override
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    await _supabase
        .from('investor_messages')
        .insert({
          'chat_id': chatId,
          'sender_id': senderId,
          'content': content,
        });
  }

  @override
  Future<InvestorMessage?> fetchLastMessage(String chatId) async {
    final response = await _supabase
        .from('investor_messages')
        .select('*, sender:profiles(full_name, avatar_url)')
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    
    if (response == null) return null;
    return InvestorMessageModel.fromJson(response);
  }

  @override
  Stream<List<InvestorMessage>> watchMessages(String chatId) {
    return _supabase
        .from('investor_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .asyncMap((event) async {
          final messages = <InvestorMessage>[];
          for (final json in event) {
            final senderResponse = await _supabase
                .from('profiles')
                .select('full_name, avatar_url')
                .eq('id', json['sender_id'])
                .single();
            
            json['sender'] = senderResponse;
            messages.add(InvestorMessageModel.fromJson(json));
          }
          return messages;
        });
  }
}
