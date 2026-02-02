import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/investor/domain/repositories/interest_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InterestRepositoryImpl implements InterestRepository {
  final SupabaseClient _supabase;

  InterestRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<void> expressInterest(String ideaId, String investorId) async {
    // Check if already exists
    final existing = await _supabase
        .from('investor_interests')
        .select()
        .eq('idea_id', ideaId)
        .eq('investor_id', investorId)
        .maybeSingle();

    if (existing != null) {
      await _supabase
          .from('investor_interests')
          .update({
            'status': 'Interested',
            'created_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
    } else {
      await _supabase.from('investor_interests').insert({
        'idea_id': ideaId,
        'investor_id': investorId,
        'status': 'Interested',
      });
    }
  }

  @override
  Future<void> bookmarkIdea(String ideaId, String investorId) async {
    final existing = await _supabase
        .from('investor_interests')
        .select()
        .eq('idea_id', ideaId)
        .eq('investor_id', investorId)
        .maybeSingle();

    if (existing != null) {
      // If currently Interested, don't downgrade to Bookmarked?
      // Or maybe 'Bookmarked' is a diverse status.
      // Let's assume user can toggle. Ideally status should be a list or separate flags.
      // For simplicity matching prompt schema: status field.
      // Let's say 'Interested' implies watching, 'Bookmarked' implies saved for later.
      // If already 'Interested', keep it. If 'Rejected', maybe update.
      if (existing['status'] != 'Interested') {
        await _supabase
            .from('investor_interests')
            .update({'status': 'Bookmarked'})
            .eq('id', existing['id']);
      }
    } else {
      await _supabase.from('investor_interests').insert({
        'idea_id': ideaId,
        'investor_id': investorId,
        'status': 'Bookmarked',
      });
    }
  }

  @override
  Future<List<String>> getInterestedIdeaIds(String investorId) async {
    final response = await _supabase
        .from('investor_interests')
        .select('idea_id')
        .eq('investor_id', investorId)
        .eq('status', 'Interested');

    return (response as List).map((e) => e['idea_id'] as String).toList();
  }

  @override
  Future<List<String>> getBookmarkedIdeaIds(String investorId) async {
    final response = await _supabase
        .from('investor_interests')
        .select('idea_id')
        .eq('investor_id', investorId)
        .eq('status', 'Bookmarked');

    return (response as List).map((e) => e['idea_id'] as String).toList();
  }
}
