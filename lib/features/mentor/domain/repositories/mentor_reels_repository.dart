import 'dart:io';
import '../entities/mentor_reel.dart';

abstract class IMentorReelsRepository {
  Future<List<MentorReel>> getReels();
  Future<void> uploadReel(String mentorId, File videoFile, String? caption);
  Future<List<MentorReel>> getMentorReels(String mentorId);
}
