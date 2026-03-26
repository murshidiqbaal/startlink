import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/team.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/entities/team_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/team_model.dart';
import '../models/team_member_model.dart';
import '../models/team_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabase;

  ChatRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<Team>> getInnovatorTeams() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('teams')
        .select('*, team_members!inner(*)')
        .eq('team_members.user_id', userId)
        .eq('team_members.role', 'admin');

    return TeamModel.fromJsonList(response);
  }

  @override
  Future<List<Team>> getCollaboratorTeams() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('teams')
        .select('*, team_members!inner(*)')
        .eq('team_members.user_id', userId)
        .eq('team_members.role', 'member');

    return TeamModel.fromJsonList(response);
  }

  @override
  Future<List<TeamMessage>> getTeamMessages(String teamId) async {
    final response = await _supabase
        .from('team_messages')
        .select('''
          id,
          team_id,
          sender_id,
          content,
          created_at,
          sender:profiles(
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('team_id', teamId)
        .order('created_at', ascending: true);

    return TeamMessageModel.fromJsonList(response);
  }

  @override
  Future<TeamMessage> sendTeamMessage(String teamId, String content) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = await _supabase.from('team_messages').insert({
      'team_id': teamId,
      'sender_id': userId,
      'content': content,
    }).select('''
      id,
      team_id,
      sender_id,
      content,
      created_at,
      sender:profiles(
        id,
        full_name,
        avatar_url
      )
    ''').single();

    return TeamMessageModel.fromJson(data);
  }

  @override
  Future<String> getOrCreateTeam(String ideaId) async {
    // Check if team exists
    final existing = await _supabase
        .from('teams')
        .select('id')
        .eq('idea_id', ideaId)
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    // Get idea owner and title to create the team
    final ideaResponse = await _supabase
        .from('ideas')
        .select('title, owner_id')
        .eq('id', ideaId)
        .single();
    
    final ideaTitle = ideaResponse['title'] as String;
    final ownerId = ideaResponse['owner_id'] as String;

    final teamResponse = await _supabase
        .from('teams')
        .insert({
          'idea_id': ideaId,
          'name': ideaTitle,
          'created_by': ownerId,
        })
        .select('id')
        .single();

    final teamId = teamResponse['id'] as String;

    // Add owner as admin
    await _supabase.from('team_members').insert({
      'team_id': teamId,
      'user_id': ownerId,
      'role': 'admin',
    });

    return teamId;
  }

  @override
  Future<List<TeamMember>> getTeamMembers(String teamId) async {
    final response = await _supabase
        .from('team_members')
        .select('''
          *,
          profiles:user_id(
            id,
            full_name,
            avatar_url
          )
        ''')
        .eq('team_id', teamId);

    return TeamMemberModel.fromJsonList(response);
  }

  @override
  Stream<List<TeamMessage>> subscribeTeamMessages(String teamId) {
    return _supabase
        .from('team_messages')
        .stream(primaryKey: ['id'])
        .eq('team_id', teamId)
        .order('created_at', ascending: true)
        .map((data) => TeamMessageModel.fromJsonList(data));
  }

  @override
  Future<bool> isTeamMember(String teamId, String userId) async {
    final response = await _supabase
        .from('team_members')
        .select('id')
        .eq('team_id', teamId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  // ── Public Discussion (groups/messages) ──────────────────────────────────

  @override
  Future<String> getOrCreatePublicGroup(String ideaId, String title) async {
    // Check for existing group
    final existing = await _supabase
        .from('groups')
        .select('id')
        .eq('idea_id', ideaId)
        .eq('type', 'public')
        .maybeSingle();

    if (existing != null) {
      return existing['id'] as String;
    }

    final response = await _supabase
        .from('groups')
        .insert({
          'idea_id': ideaId,
          'name': title,
          'type': 'public',
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  @override
  Future<List<TeamMessage>> getPublicMessages(String groupId) async {
    final response = await _supabase
        .from('messages')
        .select('*, profiles!messages_sender_id_fkey(*)')
        .eq('group_id', groupId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => TeamMessageModel.fromJson(json))
        .toList();
  }

  @override
  Future<TeamMessage> sendPublicMessage(String groupId, String content) async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('messages')
        .insert({
          'group_id': groupId,
          'sender_id': userId,
          'content': content,
        })
        .select('*, profiles!messages_sender_id_fkey(*)')
        .single();

    return TeamMessageModel.fromJson(response);
  }

  @override
  Stream<List<TeamMessage>> subscribePublicMessages(String groupId) {
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('created_at', ascending: true)
        .asyncMap((data) async {
          // Enrich with profile names for real-time
          // In a real app, you might want to cache profiles
          final messages = <TeamMessage>[];
          for (final json in data) {
             final senderId = json['sender_id'];
             final profile = await _supabase.from('profiles').select().eq('id', senderId).single();
             json['profiles'] = profile;
             messages.add(TeamMessageModel.fromJson(json));
          }
          return messages;
        });
  }
}
