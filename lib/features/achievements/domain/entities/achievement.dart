class Achievement {
  final String id;
  final String key;
  final String title;
  final String description;
  final String? iconUrl;
  final DateTime awardedAt;

  const Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    this.iconUrl,
    required this.awardedAt,
  });
}
