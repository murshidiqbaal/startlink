import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/pitch_request.dart';
import '../../domain/repositories/pitch_repository.dart';

class PitchRepositoryImpl implements PitchRepository {
  final SupabaseClient _supabase;

  PitchRepositoryImpl(this._supabase);

  @override
  Future<PitchRequest?> getPitchRequestForIdea(String ideaId, String investorId) async {
    final response = await _supabase
        .from('pitch_requests')
        .select()
        .eq('idea_id', ideaId)
        .eq('investor_id', investorId)
        .maybeSingle();

    if (response == null) return null;
    return PitchRequest.fromJson(response);
  }

  @override
  Future<void> requestPitch({
    required String ideaId,
    required String investorId,
    required String innovatorId,
  }) async {
    await _supabase.from('pitch_requests').insert({
      'idea_id': ideaId,
      'investor_id': investorId,
      'innovator_id': innovatorId,
      'status': 'pending',
    });
  }

  @override
  Future<List<PitchRequest>> fetchIncomingPitchRequests(String innovatorId) async {
    final response = await _supabase
        .from('pitch_requests')
        .select()
        .eq('innovator_id', innovatorId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => PitchRequest.fromJson(json)).toList();
  }

  @override
  Future<void> updatePitchRequestStatus({
    required String requestId,
    required PitchStatus status,
    String? pitchDeckUrl,
  }) async {
    final Map<String, dynamic> data = {
      'status': status.name,
    };
    if (pitchDeckUrl != null) {
      data['pitch_deck_url'] = pitchDeckUrl;
    }

    await _supabase
        .from('pitch_requests')
        .update(data)
        .eq('id', requestId);
  }

  @override
  Future<List<PitchRequest>> fetchInvestorPitchRequests(String investorId) async {
    final response = await _supabase
        .from('pitch_requests')
        .select('*, ideas(title)')
        .eq('investor_id', investorId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => PitchRequest.fromJson(json)).toList();
  }
}
