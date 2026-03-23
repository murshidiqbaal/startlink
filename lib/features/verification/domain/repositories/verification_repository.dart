import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class VerificationRepository {
  Future<List<UserVerification>> getVerifications(String profileId);
  Future<List<UserBadge>> getBadges(String profileId);
  Future<void> requestVerification(String profileId, String role, String type);
  Future<void> awardBadge({
    required String profileId,
    required String badgeKey,
    required String label,
    required String description,
    String? icon,
  });
}
