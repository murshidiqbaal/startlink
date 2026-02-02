import 'package:startlink/features/profile/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.userId,
    super.fullName,
    super.profilePhoto, // mapped from avatar_url or profile_photo
    super.headline,
    super.location,
    super.about,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      profilePhoto: json['profile_photo'] ?? json['avatar_url'] as String?,
      headline: json['headline'] as String?,
      location: json['location'] as String?,
      about: json['about'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'avatar_url': profilePhoto, // Keep backward compatibility if needed
      'headline': headline,
      'location': location,
      'about': about,
    };
  }

  UserProfileModel copyWith({
    String? fullName,
    String? profilePhoto,
    String? headline,
    String? location,
    String? about,
  }) {
    return UserProfileModel(
      id: id,
      userId: userId,
      fullName: fullName ?? this.fullName,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      headline: headline ?? this.headline,
      location: location ?? this.location,
      about: about ?? this.about,
    );
  }
}
