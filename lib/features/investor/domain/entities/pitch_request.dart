import 'package:equatable/equatable.dart';

enum PitchStatus { pending, approved, rejected }

class PitchRequest extends Equatable {
  final String id;
  final String investorId;
  final String ideaId;
  final String innovatorId;
  final PitchStatus status;
  final String? pitchDeckUrl;
  final DateTime createdAt;
  final String? ideaTitle;

  const PitchRequest({
    required this.id,
    required this.investorId,
    required this.ideaId,
    required this.innovatorId,
    required this.status,
    this.pitchDeckUrl,
    required this.createdAt,
    this.ideaTitle,
  });

  factory PitchRequest.fromJson(Map<String, dynamic> json) {
    return PitchRequest(
      id: json['id'],
      investorId: json['investor_id'],
      ideaId: json['idea_id'],
      innovatorId: json['innovator_id'],
      status: _parseStatus(json['status']),
      pitchDeckUrl: json['pitch_deck_url'],
      createdAt: DateTime.parse(json['created_at']),
      ideaTitle: json['ideas']?['title'],
    );
  }

  static PitchStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return PitchStatus.approved;
      case 'rejected':
        return PitchStatus.rejected;
      default:
        return PitchStatus.pending;
    }
  }

  @override
  List<Object?> get props => [id, investorId, ideaId, innovatorId, status, pitchDeckUrl, createdAt, ideaTitle];
}
