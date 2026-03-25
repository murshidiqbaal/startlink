import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/collaboration_chat.dart';
import '../../domain/repositories/collaboration_chat_repository.dart';
import '../models/collaboration_chat_model.dart';

class CollaborationChatRepositoryImpl implements CollaborationChatRepository {
  final SupabaseClient _supabase;

  CollaborationChatRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<CollaborationChat>> loadInnovatorChats() async {
    final response = await _supabase.rpc('get_innovator_chats');
    
    return (response as List).map((json) {
      return CollaborationChatModel.fromJson(json, isInnovator: true);
    }).toList();
  }

  @override
  Future<List<CollaborationChat>> loadCollaboratorChats() async {
    final response = await _supabase.rpc('get_collaborator_chats');
    
    return (response as List).map((json) {
      return CollaborationChatModel.fromJson(json, isInnovator: false);
    }).toList();
  }
}
