import 'package:equatable/equatable.dart';

class MentorReel extends Equatable {
  final String id;
  final String mentorId;
  final String videoUrl;
  final String? caption;
  final DateTime createdAt;
  final String? mentorName;
  final String? mentorAvatarUrl;

  const MentorReel({
    required this.id,
    required this.mentorId,
    required this.videoUrl,
    this.caption,
    required this.createdAt,
    this.mentorName,
    this.mentorAvatarUrl,
  });

  @override
  List<Object?> get props => [
        id,
        mentorId,
        videoUrl,
        caption,
        createdAt,
        mentorName,
        mentorAvatarUrl,
      ];
}
