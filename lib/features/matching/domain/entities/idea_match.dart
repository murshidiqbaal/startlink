import 'package:equatable/equatable.dart';

class IdeaMatch extends Equatable {
  final String id;
  final String ideaId;
  final String matchedProfileId;
  final String matchedProfileName; // Denormalized for UI convenience
  final String? matchedProfileAvatarUrl; // Denormalized for UI convenience
  final String role;
  final int matchScore;
  final Map<String, dynamic> matchReason;

  const IdeaMatch({
    required this.id,
    required this.ideaId,
    required this.matchedProfileId,
    required this.matchedProfileName,
    this.matchedProfileAvatarUrl,
    required this.role,
    required this.matchScore,
    required this.matchReason,
  });

  @override
  List<Object?> get props => [
    id,
    ideaId,
    matchedProfileId,
    matchedProfileName,
    matchedProfileAvatarUrl,
    role,
    matchScore,
    matchReason,
  ];
}
