import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

class UserVerificationModel extends UserVerification {
  const UserVerificationModel({
    required super.id,
    required super.profileId,
    required super.role,
    required super.verificationType,
    required super.status,
    super.verifiedAt,
    required super.createdAt,
    super.fullName,
    super.email,
  });

  factory UserVerificationModel.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return UserVerificationModel(
      id: json['id'],
      profileId: json['profile_id'],
      role: json['role'],
      verificationType: json['verification_type'],
      status: json['status'],
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      fullName: profile != null ? profile['full_name'] : null,
      email: profile != null ? profile['email'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'role': role,
      'verification_type': verificationType,
      'status': status,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserBadgeModel extends UserBadge {
  const UserBadgeModel({
    required super.id,
    required super.profileId,
    required super.badgeKey,
    required super.badgeLabel,
    super.badgeDescription,
    super.icon,
    required super.awardedAt,
    required super.name,
  });

  factory UserBadgeModel.fromJson(Map<String, dynamic> json) {
    return UserBadgeModel(
      id: json['id'],
      profileId: json['profile_id'],
      badgeKey: json['badge_key'],
      badgeLabel: json['badge_label'],
      badgeDescription: json['badge_description'],
      icon: json['icon'],
      awardedAt: DateTime.parse(json['awarded_at']),
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'badge_key': badgeKey,
      'badge_label': badgeLabel,
      'badge_description': badgeDescription,
      'icon': icon,
      'name': name,
      'awarded_at': awardedAt.toIso8601String(),
    };
  }
}
