import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/mentor_chat.dart';
import '../../domain/repositories/mentor_chat_repository.dart';
import '../models/mentor_chat_model.dart';

class MentorChatRepositoryImpl implements IMentorChatRepository {
  final SupabaseClient _supabase;

  MentorChatRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<MentorChat>> getMentorChats(String mentorId) async {
    final response = await _supabase
        .from('mentor_chats')
        .select('''
          *,
          user_profile:profiles!mentor_chats_user_id_fkey(*),
          idea:ideas(*)
        ''')
        .eq('mentor_id', mentorId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => MentorChatModel.fromJson(json)).toList();
  }

  @override
  Future<List<MentorMessage>> getChatMessages(String chatId) async {
    final response = await _supabase
        .from('mentor_messages')
        .select('''
          *,
          sender_profile:profiles!mentor_messages_sender_id_fkey(*)
        ''')
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return (response as List).map((json) => MentorMessageModel.fromJson(json)).toList();
  }

  @override
  Future<void> sendChatMessage(String chatId, String senderId, String content) async {
    await _supabase.from('mentor_messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'content': content,
    });
  }

  @override
  Stream<List<MentorMessage>> subscribeToMessages(String chatId) {
    return _supabase
        .from('mentor_messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: true)
        .asyncMap((data) async {
          final messages = <MentorMessageModel>[];
          for (final json in data) {
            final senderId = json['sender_id'];
            final profile = await _supabase.from('profiles').select().eq('id', senderId).single();
            json['sender_profile'] = profile;
            messages.add(MentorMessageModel.fromJson(json));
          }
          return messages;
        });
  }

  @override
  Future<MentorChat> createOrFetchChat(String mentorId, String userId, String ideaId) async {
    final existing = await _supabase
        .from('mentor_chats')
        .select()
        .eq('mentor_id', mentorId)
        .eq('user_id', userId)
        .eq('idea_id', ideaId)
        .maybeSingle();

    if (existing != null) {
      return MentorChatModel.fromJson(existing);
    }

    final response = await _supabase
        .from('mentor_chats')
        .insert({
          'mentor_id': mentorId,
          'user_id': userId,
          'idea_id': ideaId,
        })
        .select('''
          *,
          user_profile:profiles!mentor_chats_user_id_fkey(*),
          idea:ideas(*)
        ''')
        .single();

    return MentorChatModel.fromJson(response);
  }
}
