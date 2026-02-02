import 'package:startlink/features/idea_dna/domain/entities/idea_dna.dart';

class IdeaDnaModel extends IdeaDna {
  const IdeaDnaModel({
    required super.ideaId,
    required super.market,
    required super.risk,
    required super.innovation,
    required super.revenue,
    required super.overallScore,
  });

  factory IdeaDnaModel.fromJson(Map<String, dynamic> json) {
    return IdeaDnaModel(
      ideaId: json['idea_id'] ?? '',
      overallScore: (json['overall_score'] ?? 0).toDouble(),
      market: DnaDimensionModel.fromJson(json['market'] ?? {}),
      risk: DnaDimensionModel.fromJson(json['risk'] ?? {}),
      innovation: DnaDimensionModel.fromJson(json['innovation'] ?? {}),
      revenue: DnaDimensionModel.fromJson(json['revenue'] ?? {}),
    );
  }
}

class DnaDimensionModel extends DnaDimension {
  const DnaDimensionModel({
    required super.score,
    required super.metrics,
    required super.summary,
  });

  factory DnaDimensionModel.fromJson(Map<String, dynamic> json) {
    return DnaDimensionModel(
      score: (json['score'] ?? 0).toDouble(),
      summary: json['summary'] ?? '',
      metrics: (json['metrics'] as List? ?? [])
          .map((m) => DnaMetricModel.fromJson(m))
          .toList(),
    );
  }
}

class DnaMetricModel extends DnaMetric {
  const DnaMetricModel({required super.label, required super.value});

  factory DnaMetricModel.fromJson(Map<String, dynamic> json) {
    return DnaMetricModel(
      label: json['label'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}
