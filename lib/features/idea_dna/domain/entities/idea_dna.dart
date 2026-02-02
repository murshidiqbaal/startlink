import 'package:equatable/equatable.dart';

class IdeaDna extends Equatable {
  final String ideaId;
  final DnaDimension market;
  final DnaDimension risk;
  final DnaDimension innovation;
  final DnaDimension revenue;
  final double overallScore;

  const IdeaDna({
    required this.ideaId,
    required this.market,
    required this.risk,
    required this.innovation,
    required this.revenue,
    required this.overallScore,
  });

  @override
  List<Object?> get props => [
    ideaId,
    market,
    risk,
    innovation,
    revenue,
    overallScore,
  ];
}

class DnaDimension extends Equatable {
  final double score; // 0-100
  final List<DnaMetric> metrics;
  final String summary;

  const DnaDimension({
    required this.score,
    required this.metrics,
    required this.summary,
  });

  @override
  List<Object?> get props => [score, metrics, summary];
}

class DnaMetric extends Equatable {
  final String label;
  final double value; // 0-100

  const DnaMetric({required this.label, required this.value});

  @override
  List<Object?> get props => [label, value];
}
