import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/collaboration/data/models/collaboration_model.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CollaborationRepositoryImpl implements CollaborationRepository {
  final SupabaseClient _supabase;

  CollaborationRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<void> applyForCollaboration({
    required String ideaId,
    required String innovatorId,
    required String roleApplied,
    required String message,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Prevent applying to own idea
    if (user.id == innovatorId) {
      throw Exception('You cannot apply to your own idea');
    }

    // Check for duplicate application
    final existing = await _supabase
        .from('idea_collaborations')
        .select()
        .eq('idea_id', ideaId)
        .eq('collaborator_id', user.id)
        .maybeSingle();

    if (existing != null) {
      throw Exception('You have already applied to this idea');
    }

    await _supabase.from('idea_collaborations').insert({
      'idea_id': ideaId,
      'collaborator_id': user.id,
      'innovator_id': innovatorId,
      'role_applied': roleApplied,
      'message': message,
      'status': 'Pending',
      'applied_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Collaboration>> fetchMyCollaborations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('idea_collaborations')
        .select('*, ideas(title)')
        .eq('collaborator_id', user.id)
        .order('applied_at', ascending: false);

    return (response as List)
        .map((json) => CollaborationModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<Collaboration>> fetchCollaborationsForIdea(String ideaId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('idea_collaborations')
        .select('*, profiles(full_name, avatar_url, headline)')
        .eq('idea_id', ideaId)
        .order('applied_at', ascending: false); // Newest first

    return (response as List)
        .map((json) => CollaborationModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> updateCollaborationStatus({
    required String collaborationId,
    required String status,
  }) async {
    final validStatuses = ['Accepted', 'Rejected', 'Withdrawn'];
    if (!validStatuses.contains(status)) {
      throw Exception('Invalid status');
    }

    await _supabase
        .from('idea_collaborations')
        .update({
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', collaborationId);
  }

  @override
  Future<List<Collaboration>> fetchReceivedCollaborations() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final response = await _supabase
        .from('idea_collaborations')
        .select(
          '*, ideas(title), profiles(full_name, avatar_url, headline)',
        ) // Join ideas to get title, join profiles to get applicant info
        .eq('innovator_id', user.id)
        .order('applied_at', ascending: false);

    return (response as List)
        .map((json) => CollaborationModel.fromJson(json))
        .toList();
  }
}
