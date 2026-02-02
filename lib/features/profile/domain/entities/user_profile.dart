import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String userId;
  final String? fullName;
  final String? profilePhoto;
  final String? headline;
  final String? location;
  final String? about;

  const UserProfile({
    required this.id,
    required this.userId,
    this.fullName,
    this.profilePhoto,
    this.headline,
    this.location,
    this.about,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    fullName,
    profilePhoto,
    headline,
    location,
    about,
  ];
}
