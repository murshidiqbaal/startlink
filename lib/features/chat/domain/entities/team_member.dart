import 'package:equatable/equatable.dart';

class TeamMember extends Equatable {
  final String id;
  final String teamId;
  final String userId;
  final String role; // 'admin' or 'member'
  final DateTime joinedAt;
  final String? fullName;
  final String? avatarUrl;

  const TeamMember({
    required this.id,
    required this.teamId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, teamId, userId, role, joinedAt, fullName, avatarUrl];
}
