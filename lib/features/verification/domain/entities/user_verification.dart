class UserVerification {
  final String id;
  final String profileId;
  final String role;
  final String verificationType;
  final String status;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  const UserVerification({
    required this.id,
    required this.profileId,
    required this.role,
    required this.verificationType,
    required this.status,
    this.verifiedAt,
    required this.createdAt,
  });

  bool get isApproved => status == 'Approved';
  bool get isPending => status == 'Pending';
  bool get isRejected => status == 'Rejected';
}
