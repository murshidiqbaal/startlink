import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class AdminVerificationRepository {
  Future<List<UserVerification>> getPendingVerifications();
  Future<List<UserVerification>> getApprovedVerifications();
  Future<List<UserVerification>> getRejectedVerifications();

  Future<void> approveVerification(String verificationId, String profileId);
  Future<void> rejectVerification(String verificationId, String reason);
}
