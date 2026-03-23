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
  });

  bool get isApproved => status == 'Approved';
  bool get isPending => status == 'Pending';
  bool get isRejected => status == 'Rejected';

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
