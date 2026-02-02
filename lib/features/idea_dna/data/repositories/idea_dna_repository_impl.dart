import 'package:startlink/features/idea_dna/data/models/idea_dna_model.dart';
import 'package:startlink/features/idea_dna/domain/entities/idea_dna.dart';
import 'package:startlink/features/idea_dna/domain/repositories/idea_dna_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdeaDnaRepositoryImpl implements IdeaDnaRepository {
  final SupabaseClient _supabase;

  IdeaDnaRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<IdeaDna> getIdeaDna(String ideaId) async {
    try {
      // 1. Try to get cached DNA from database
      final response = await _supabase
          .from('idea_dna')
          .select()
          .eq('idea_id', ideaId)
          .maybeSingle();

      if (response != null) {
        return IdeaDnaModel.fromJson(response);
      }

      // 2. If not found, call Edge Function to generate it
      final functionResponse = await _supabase.functions.invoke(
        'analyze-dna',
        body: {'idea_id': ideaId},
      );

      if (functionResponse.status != 200) {
        throw Exception('Failed to generate DNA analysis');
      }

      final dnaData = functionResponse.data;

      // Optionally cache it locally or rely on the function to have saved it
      return IdeaDnaModel.fromJson(dnaData);
    } catch (e) {
      throw Exception('Error fetching Idea DNA: $e');
    }
  }
}
