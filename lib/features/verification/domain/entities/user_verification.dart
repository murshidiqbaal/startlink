import 'package:equatable/equatable.dart';

class UserVerification extends Equatable {
  final String id;
  final String profileId;
  final String role;
  final String verificationType;
  final String status;
  final DateTime? verifiedAt;
  final DateTime createdAt;
  final String? fullName;
  final String? email;
  final String? rejectionReason;

  const UserVerification({
    required this.id,
    required this.profileId,
    required this.role,
    required this.verificationType,
    required this.status,
    this.verifiedAt,
    required this.createdAt,
    this.fullName,
    this.email,
    this.rejectionReason,
  });

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  @override
  List<Object?> get props => [
        id,
        profileId,
        role,
        verificationType,
        status,
        verifiedAt,
        createdAt,
        fullName,
        email,
      ];
}
