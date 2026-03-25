import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';

class IdeaTeamMemberModel extends IdeaTeamMember {
  const IdeaTeamMemberModel({
    required super.userId,
    required super.role,
    required super.fullName,
    super.avatarUrl,
  });

  factory IdeaTeamMemberModel.fromJson(Map<String, dynamic> json) {
    return IdeaTeamMemberModel(
      userId: json['user_id'] as String,
      role: json['role'] as String,
      fullName: json['profiles'] != null ? json['profiles']['full_name'] as String : 'Unknown',
      avatarUrl: json['profiles'] != null ? json['profiles']['avatar_url'] as String? : null,
    );
  }
}
