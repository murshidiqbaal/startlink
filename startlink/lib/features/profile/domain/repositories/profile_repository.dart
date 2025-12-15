import 'package:startlink/features/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel?> getMyProfile();
  Future<void> updateProfile(ProfileModel profile);
}
