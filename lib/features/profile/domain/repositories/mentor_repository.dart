import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class MentorRepository {
  Future<MentorProfile?> getProfile(String userId);
  Future<void> updateProfile(MentorProfile profile);
  Future<void> submitVerification(String userId);
  Future<UserVerification?> getVerificationStatus(String userId);
}
