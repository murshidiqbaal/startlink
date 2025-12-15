import 'package:startlink/features/profile/data/models/profile_model.dart';

abstract class ProfileRepository {
  Future<ProfileModel?> getMyProfile();
  Future<void> updateProfile(ProfileModel profile);
  Future<String?> uploadAvatar(
    dynamic imageFile,
  ); // Accepting File or XFile as dynamic to avoid dependency here or abstract it
}
