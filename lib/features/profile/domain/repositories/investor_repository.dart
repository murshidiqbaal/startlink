import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

abstract class InvestorRepository {
  Future<InvestorProfile?> getProfile(String userId);
  Future<void> updateProfile(InvestorProfile profile);
  Future<void> submitVerification(String userId);
  Future<UserVerification?> getVerificationStatus(String userId);
}
