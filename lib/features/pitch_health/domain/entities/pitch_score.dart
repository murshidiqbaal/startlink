import 'package:equatable/equatable.dart';

class PitchScore extends Equatable {
  final int overallScore; // 0-100
  final int clarity;
  final int marketFit;
  final int investorReadiness;
  final int storytelling;
  final List<String> suggestions;

  const PitchScore({
    required this.overallScore,
    required this.clarity,
    required this.marketFit,
    required this.investorReadiness,
    required this.storytelling,
    required this.suggestions,
  });

  factory PitchScore.empty() => const PitchScore(
    overallScore: 0,
    clarity: 0,
    marketFit: 0,
    investorReadiness: 0,
    storytelling: 0,
    suggestions: [],
  );

  @override
  List<Object?> get props => [
    overallScore,
    clarity,
    marketFit,
    investorReadiness,
    storytelling,
    suggestions,
  ];
}
