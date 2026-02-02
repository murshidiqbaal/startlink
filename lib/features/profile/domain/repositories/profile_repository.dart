import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/user_profile.dart';

abstract class ProfileRepository {
  Future<ProfileModel?> getMyProfile();
  Future<void> updateProfile(ProfileModel profile);
  Future<String?> uploadAvatar(
    dynamic imageFile,
  ); // Accepting File or XFile as dynamic to avoid dependency here or abstract it
  Future<ProfileModel?> getProfileById(String userId);

  // New Role-Specific Methods
  Future<UserProfile?> getUserProfile(String userId);
  Future<InnovatorProfile?> getInnovatorProfile(String profileId);
  Future<MentorProfile?> getMentorProfile(String profileId);
  Future<InvestorProfile?> getInvestorProfile(String profileId);

  Future<void> updateInnovatorProfile(InnovatorProfile profile);
  Future<void> updateMentorProfile(MentorProfile profile);
  Future<void> updateInvestorProfile(InvestorProfile profile);
}
