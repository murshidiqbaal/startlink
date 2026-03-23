class CoFounderResponse {
  final String reply;
  final List<String> insights;
  final List<String> actionItems;
  final List<String> risks;

  CoFounderResponse({
    required this.reply,
    required this.insights,
    required this.actionItems,
    required this.risks,
  });

  factory CoFounderResponse.fromJson(Map<String, dynamic> json) {
    return CoFounderResponse(
      reply: json['reply'] as String? ?? 'No response',
      insights:
          (json['insights'] as List?)?.map((e) => e.toString()).toList() ?? [],
      actionItems:
          (json['action_items'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      risks: (json['risks'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
