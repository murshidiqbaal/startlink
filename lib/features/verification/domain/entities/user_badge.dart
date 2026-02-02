class UserBadge {
  final String id;
  final String profileId;
  final String badgeKey;
  final String badgeLabel;
  final String? badgeDescription;
  final String? icon;
  final DateTime awardedAt;

  const UserBadge({
    required this.id,
    required this.profileId,
    required this.badgeKey,
    required this.badgeLabel,
    this.badgeDescription,
    this.icon,
    required this.awardedAt,
  });
}
