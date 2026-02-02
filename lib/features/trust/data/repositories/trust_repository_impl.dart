import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/trust/domain/repositories/trust_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrustRepositoryImpl implements TrustRepository {
  final SupabaseClient _supabase;

  TrustRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? SupabaseService.client;

  @override
  Future<int> getTrustScore(String profileId) async {
    try {
      final response = await _supabase
          .from('user_trust_scores')
          .select('trust_score')
          .eq('profile_id', profileId)
          .maybeSingle();

      return response?['trust_score'] as int? ?? 0;
    } catch (e) {
      return 0; // Default if error or not found
    }
  }

  @override
  Future<void> updateTrustScore(
    String profileId,
    String role,
    int score,
  ) async {
    try {
      await _supabase.from('user_trust_scores').upsert({
        'profile_id': profileId,
        'role': role,
        'trust_score': score,
        'last_calculated': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to update trust score: $e');
    }
  }
}
