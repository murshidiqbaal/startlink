class AIInsight {
  final String ideaId;
  final String? summary;
  final List<String> strengths;
  final List<String> risks;
  final String marketPotential;
  final String executionRisk;

  // Dynamic calculation for investor specific fit
  final int? personalFitScore;
  final List<String>? fitReasons;

  const AIInsight({
    required this.ideaId,
    this.summary,
    this.strengths = const [],
    this.risks = const [],
    this.marketPotential = 'Unknown',
    this.executionRisk = 'Unknown',
    this.personalFitScore,
    this.fitReasons,
  });
}
