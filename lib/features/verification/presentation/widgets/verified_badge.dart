import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class VerifiedBadge extends StatelessWidget {
  final double size;
  final Color? color;

  const VerifiedBadge({
    super.key,
    this.size = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: (color ?? AppColors.brandPurple).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.verified_rounded,
        size: size,
        color: color ?? AppColors.brandPurple,
      ),
    );
  }
}
