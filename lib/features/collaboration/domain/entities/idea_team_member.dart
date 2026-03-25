import 'package:equatable/equatable.dart';

class IdeaTeamMember extends Equatable {
  final String userId;
  final String role;
  final String fullName;
  final String? avatarUrl;

  const IdeaTeamMember({
    required this.userId,
    required this.role,
    required this.fullName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [
        userId,
        role,
        fullName,
        avatarUrl,
      ];
}
