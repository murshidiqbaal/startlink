// lib/features/chat/data/repositories/chat_repository_impl.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;

  ChatRepositoryImpl(this._supabase);

  @override
  Future<List<ChatRoom>> getInnovatorChatRooms() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('ideas')
        .select('*, chat_rooms!inner(*)')
        .eq('owner_id', userId);

    final List<ChatRoom> rooms = [];
    for (var idea in response) {
      final roomData = idea['chat_rooms'];
      if (roomData != null) {
        // Since it's a 1:1, it might be a Map or a List depending on the query
        if (roomData is List && roomData.isNotEmpty) {
          rooms.add(ChatRoomModel.fromJson({
            ...roomData[0],
            'ideas': {'title': idea['title']}
          }));
        } else if (roomData is Map) {
          rooms.add(ChatRoomModel.fromJson({
            ...roomData,
            'ideas': {'title': idea['title']}
          }));
        }
      }
    }
    return rooms;
  }

  @override
  Future<List<ChatRoom>> getCollaboratorChatRooms() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('idea_collaborators')
        .select('ideas!inner(id, title, chat_rooms!inner(*))')
        .eq('user_id', userId)
        .eq('status', 'Accepted');

    final List<ChatRoom> rooms = [];
    for (var item in response) {
      final idea = item['ideas'];
      final roomData = idea['chat_rooms'];
      if (roomData != null) {
        if (roomData is List && roomData.isNotEmpty) {
          rooms.add(ChatRoomModel.fromJson({
            ...roomData[0],
            'ideas': {'title': idea['title']}
          }));
        } else if (roomData is Map) {
          rooms.add(ChatRoomModel.fromJson({
            ...roomData,
            'ideas': {'title': idea['title']}
          }));
        }
      }
    }
    return rooms;
  }

  @override
  Future<List<Message>> getMessages(String roomId) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: true);

    return MessageModel.fromJsonList(response);
  }

  @override
  Future<void> sendMessage(String roomId, String message) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _supabase.from('messages').insert({
      'room_id': roomId,
      'sender_id': userId,
      'message': message,
    });
  }

  @override
  Future<String> getOrCreateRoom(String ideaId) async {
    final existing = await _supabase
        .from('chat_rooms')
        .select('id')
        .eq('idea_id', ideaId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final response = await _supabase
        .from('chat_rooms')
        .insert({'idea_id': ideaId})
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getTeamMembers(String ideaId) async {
    final idea = await _supabase
        .from('ideas')
        .select('owner_id, profiles!owner_id(full_name, avatar_url)')
        .eq('id', ideaId)
        .single();
    
    final collaborators = await _supabase
        .from('idea_collaborators')
        .select('user_id, profiles!user_id(full_name, avatar_url)')
        .eq('idea_id', ideaId)
        .eq('status', 'Accepted');

    final List<Map<String, dynamic>> members = [];
    
    // Add owner
    if (idea['profiles'] != null) {
      members.add({
        'user_id': idea['owner_id'],
        'full_name': idea['profiles']['full_name'],
        'avatar_url': idea['profiles']['avatar_url'],
      });
    }

    // Add collaborators
    for (var c in collaborators) {
      if (c['profiles'] != null) {
        members.add({
          'user_id': c['user_id'],
          'full_name': c['profiles']['full_name'],
          'avatar_url': c['profiles']['avatar_url'],
        });
      }
    }
    return members;
  }

  @override
  Stream<List<Message>> subscribeMessages(String roomId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((data) => MessageModel.fromJsonList(data));
  }

  @override
  Future<bool> isTeamMember(String ideaId, String userId) async {
    final idea = await _supabase
        .from('ideas')
        .select('owner_id')
        .eq('id', ideaId)
        .maybeSingle();
    
    if (idea != null && idea['owner_id'] == userId) return true;

    final collaborator = await _supabase
        .from('idea_collaborators')
        .select()
        .eq('idea_id', ideaId)
        .eq('user_id', userId)
        .eq('status', 'Accepted')
        .maybeSingle();

    return collaborator != null;
  }
}
