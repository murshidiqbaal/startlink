import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/collaboration/data/models/collaboration_request_model.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';
import 'package:startlink/features/collaboration/data/models/idea_team_member_model.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollaborationRepositoryImpl implements CollaborationRepository {
  final SupabaseClient _supabase;

  CollaborationRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<void> applyForIdea({
    required String ideaId,
    required String innovatorId,
    required String roleApplied,
    required String message,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    if (user.id == innovatorId) {
      throw Exception('You cannot apply to your own idea');
    }

    try {
      await _supabase.from('collaboration_requests').insert({
        'idea_id': ideaId,
        'applicant_id': user.id,
        'innovator_id': innovatorId,
        'role_applied': roleApplied,
        'message': message,
        'status': 'pending',
      });
    } catch (e) {
      if (e.toString().contains('unique_application')) {
        throw Exception('You have already applied for this idea');
      }
      rethrow;
    }
  }

  @override
  Future<List<CollaborationRequest>> getIdeaApplications(String ideaId) async {
    final response = await _supabase
        .from('collaboration_requests')
        .select('''
          *,
          ideas(title),
          applicant:profiles!collaboration_requests_applicant_id_fkey(
            id,
            full_name,
            avatar_url,
            headline
          )
        ''')
        .eq('idea_id', ideaId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CollaborationRequestModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> updateApplicationStatus({
    required String requestId,
    required String status,
  }) async {
    await _supabase
        .from('collaboration_requests')
        .update({'status': status})
        .eq('request_id', requestId);
  }

  @override
  Future<List<CollaborationRequest>> fetchMyCollaborations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('collaboration_requests')
        .select('''
          *,
          ideas(title),
          innovator:profiles!collaboration_requests_innovator_id_fkey(
            id,
            full_name,
            avatar_url,
            headline
          )
        ''')
        .eq('applicant_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CollaborationRequestModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<CollaborationRequest>> fetchReceivedCollaborations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('collaboration_requests')
        .select('''
          *,
          ideas(title),
          applicant:profiles!collaboration_requests_applicant_id_fkey(
            id,
            full_name,
            avatar_url,
            headline
          )
        ''')
        .eq('innovator_id', user.id)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CollaborationRequestModel.fromJson(json))
        .toList();
  }
  @override
  Future<List<IdeaTeamMember>> fetchIdeaTeamMembers(String ideaId) async {
    final response = await _supabase
        .from('idea_collaborators')
        .select('''
          user_id,
          role,
          profiles!idea_collaborators_user_id_fkey(
            full_name,
            avatar_url
          )
        ''')
        .eq('idea_id', ideaId);

    return (response as List)
        .map((json) => IdeaTeamMemberModel.fromJson(json))
        .toList();
  }
}
