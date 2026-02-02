import 'package:flutter/material.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'badge_display.dart';

class VerificationBadgeRow extends StatelessWidget {
  final List<UserBadge> badges;

  const VerificationBadgeRow({super.key, required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: badges.map((badge) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: BadgeDisplay(
              label: badge.badgeLabel,
              iconName: badge.badgeKey,
              color: _getBadgeColor(badge.badgeKey),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getBadgeColor(String key) {
    switch (key) {
      case 'profile_verified':
        return Colors.blue;
      case 'active_innovator':
        return Colors.amber;
      case 'trusted_mentor':
        return Colors.green;
      case 'verified_investor':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
