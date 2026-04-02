import '../../domain/entities/mentor_reel.dart';

class MentorReelModel extends MentorReel {
  const MentorReelModel({
    required super.id,
    required super.mentorId,
    required super.videoUrl,
    super.caption,
    required super.createdAt,
    super.mentorName,
    super.mentorAvatarUrl,
  });

  factory MentorReelModel.fromJson(Map<String, dynamic> json) {
    final profile = json['mentor'] as Map<String, dynamic>?;
    
    return MentorReelModel(
      id: json['id'] as String,
      mentorId: json['mentor_id'] as String,
      videoUrl: json['video_url'] as String,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      mentorName: profile?['full_name'] as String?,
      mentorAvatarUrl: profile?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mentor_id': mentorId,
      'video_url': videoUrl,
      'caption': caption,
    };
  }
}
