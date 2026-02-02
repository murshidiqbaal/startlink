import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class VerificationRepository {
  Future<List<UserVerification>> getVerifications(String profileId);
  Future<List<UserBadge>> getBadges(String profileId);
  Future<void> requestVerification(String profileId, String role, String type);
  Future<void> awardBadge(
    String profileId,
    String badgeKey,
    String label,
    String description,
  ); // For auto-award logic
}
