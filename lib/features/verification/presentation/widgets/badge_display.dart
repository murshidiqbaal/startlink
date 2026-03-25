import 'package:flutter/material.dart';

class BadgeDisplay extends StatelessWidget {
  final String label;
  final String? iconName; // e.g., 'verified_user' mapped to IconData
  final Color? color;
  final bool isCompact;

  const BadgeDisplay({
    super.key,
    required this.label,
    this.iconName,
    this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Tooltip(
        message: label,
        child: Icon(
          _getIconData(iconName),
          size: 16,
          color: color ?? Colors.blue,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: (color ?? Colors.blue).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIconData(iconName), size: 14, color: color ?? Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? name) {
    switch (name) {
      case 'profile_verified':
        return Icons.verified;
      case 'trusted_mentor':
        return Icons.school;
      case 'verified_investor':
        return Icons.monetization_on;
      case 'active_innovator':
        return Icons.lightbulb;
      default:
        return Icons.star;
    }
  }
}
