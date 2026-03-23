import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostIdeaRepository {
  final SupabaseClient _supabase;

  PostIdeaRepository(this._supabase);

  /// Uploads cover image to Supabase Storage (`idea-covers` bucket)
  /// and returns the public URL.
  Future<String?> uploadCoverImage(File imageFile, String userId) async {
    try {
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$userId.$fileExt';
      const bucket = 'idea-covers';

      await _supabase.storage
          .from(bucket)
          .upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _supabase.storage.from(bucket).getPublicUrl(fileName);
    } catch (e) {
      debugPrint('[PostIdeaRepository] uploadCoverImage error: $e');
      throw Exception('Failed to upload cover image: $e');
    }
  }

  /// Inserts a new idea into the `ideas` table.
  /// All fields must exactly match existing DB columns.
  Future<void> insertIdea(Map<String, dynamic> ideaData) async {
    try {
      await _supabase.from('ideas').insert(ideaData);
      debugPrint('[PostIdeaRepository] Idea inserted successfully.');
    } on PostgrestException catch (e) {
      debugPrint('[PostIdeaRepository] PostgrestException: ${e.message}');
      throw Exception('Database Error: ${e.message}');
    } catch (e) {
      debugPrint('[PostIdeaRepository] insertIdea error: $e');
      throw Exception('Failed to post idea: $e');
    }
  }
}
