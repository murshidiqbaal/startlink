import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';
import '../../domain/entities/chat_room.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;

  ChatRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<ChatGroup>> getInnovatorGroups() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('groups')
        .select('*, ideas!inner(*)')
        .eq('type', 'team')
        .eq('ideas.owner_id', userId);

    return ChatGroupModel.fromJsonList(response);
  }

  @override
  Future<List<ChatGroup>> getCollaboratorGroups() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('groups')
        .select('*, ideas!inner(idea_collaborators!inner(*))')
        .eq('type', 'team')
        .eq('ideas.idea_collaborators.user_id', userId)
        .eq('ideas.idea_collaborators.status', 'Accepted');

    return ChatGroupModel.fromJsonList(response);
  }

  @override
  Future<List<Message>> getMessages(String groupId) async {
    final response = await _supabase
        .from('messages')
        .select('''
          id,
          group_id,
          sender_id,
          content,
          is_read,
          created_at,
          sender:profiles(
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('group_id', groupId)
        .order('created_at', ascending: true);

    return MessageModel.fromJsonList(response);
  }

  @override
  Future<Message> sendMessage(String groupId, String message) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = await _supabase.from('messages').insert({
      'group_id': groupId,
      'sender_id': userId,
      'content': message,
      'is_read': false,
    }).select('''
      id,
      group_id,
      sender_id,
      content,
      is_read,
      created_at,
      sender:profiles(
        id,
        full_name,
        avatar_url
      )
    ''').single();

    return MessageModel.fromJson(data);
  }

  @override
  Future<String> getOrCreateGroup(String ideaId, {String type = 'team'}) async {
    final existing = await _supabase
        .from('groups')
        .select('id')
        .eq('idea_id', ideaId)
        .eq('type', type)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Get idea title for the group name
    final ideaResponse = await _supabase
        .from('ideas')
        .select('title')
        .eq('id', ideaId)
        .single();
    final ideaTitle = ideaResponse['title'] as String;

    final response = await _supabase
        .from('groups')
        .insert({
          'idea_id': ideaId,
          'type': type,
          'name': type == 'public' ? '$ideaTitle (Community)' : ideaTitle,
        })
        .select('id')
        .single();

    return response['id'] as String;
  }



  @override
  Future<List<IdeaTeamMember>> getTeamMembers(String ideaId) async {
    final idea = await _supabase
        .from('ideas')
        .select('owner_id, profiles!owner_id(full_name, avatar_url)')
        .eq('id', ideaId)
        .single();
    
    final collaborators = await _supabase
        .from('idea_collaborators')
        .select('user_id, role, profiles!user_id(full_name, avatar_url)')
        .eq('idea_id', ideaId)
        .eq('status', 'Accepted');

    final List<IdeaTeamMember> members = [];
    
    if (idea['profiles'] != null) {
      members.add(IdeaTeamMember(
        userId: idea['owner_id'] as String,
        fullName: idea['profiles']['full_name'] as String? ?? 'Idea Owner',
        avatarUrl: idea['profiles']['avatar_url'] as String?,
        role: 'Innovator',
      ));
    }

    for (var c in collaborators as List) {
      if (c['profiles'] != null) {
        members.add(IdeaTeamMember(
          userId: c['user_id'] as String,
          fullName: c['profiles']['full_name'] as String? ?? 'Collaborator',
          avatarUrl: c['profiles']['avatar_url'] as String?,
          role: c['role'] as String? ?? 'Team Member',
        ));
      }
    }

    return members;
  }

  @override
  Stream<List<Message>> subscribeMessages(String groupId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
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
