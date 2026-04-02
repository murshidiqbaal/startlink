import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/mentor_reel.dart';
import '../../domain/repositories/mentor_reels_repository.dart';
import '../models/mentor_reel_model.dart';

class MentorReelsRepositoryImpl implements IMentorReelsRepository {
  final SupabaseClient _supabase;

  MentorReelsRepositoryImpl({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  @override
  Future<List<MentorReel>> getReels() async {
    final response = await _supabase
        .from('mentor_reels')
        .select('''
          *,
          mentor:profiles(*)
        ''')
        .order('created_at', ascending: false);

    return (response as List).map((json) => MentorReelModel.fromJson(json)).toList();
  }

  @override
  Future<void> uploadReel(String mentorId, File videoFile, String? caption) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'reels/$mentorId/$timestamp.mp4';

    await _supabase.storage.from('mentor-reels').upload(path, videoFile);

    final videoUrl = _supabase.storage.from('mentor-reels').getPublicUrl(path);

    await _supabase.from('mentor_reels').insert({
      'mentor_id': mentorId,
      'video_url': videoUrl,
      'caption': caption,
    });
  }

  @override
  Future<List<MentorReel>> getMentorReels(String mentorId) async {
    final response = await _supabase
        .from('mentor_reels')
        .select('''
          *,
          mentor:profiles(*)
        ''')
        .eq('mentor_id', mentorId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => MentorReelModel.fromJson(json)).toList();
  }
}
