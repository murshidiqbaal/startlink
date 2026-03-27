// lib/features/profile/presentation/widgets/verification_status_card.dart

import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';

class VerificationStatusCard extends StatelessWidget {
  final VerificationStatus status;
  final String role;
  final String? customSubtitle;
  final VoidCallback? onActionPressed;

  const VerificationStatusCard({
    super.key,
    required this.status,
    required this.role,
    this.customSubtitle,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case VerificationStatus.verified:
        return _buildCard(
          context,
          icon: Icons.verified_user_rounded,
          iconColor: AppColors.emerald,
          title: 'Verified ${role[0].toUpperCase()}${role.substring(1)}',
          subtitle: customSubtitle ?? 'Your identity has been confirmed.',
          borderColor: AppColors.emerald.withValues(alpha: 0.3),
          backgroundColor: AppColors.emerald.withValues(alpha: 0.1),
        );
      case VerificationStatus.pending:
        return _buildCard(
          context,
          icon: Icons.pending_actions_rounded,
          iconColor: AppColors.amber,
          title: 'Verification Pending',
          subtitle: customSubtitle ?? 'Your profile is under review.',
          borderColor: AppColors.amber.withValues(alpha: 0.3),
          backgroundColor: AppColors.amber.withValues(alpha: 0.1),
        );
      case VerificationStatus.rejected:
        return _buildCard(
          context,
          icon: Icons.error_outline_rounded,
          iconColor: AppColors.rose,
          title: 'Verification Rejected',
          subtitle: customSubtitle ?? 'Please review and re-submit your profile.',
          borderColor: AppColors.rose.withValues(alpha: 0.3),
          backgroundColor: AppColors.rose.withValues(alpha: 0.1),
        );
      case VerificationStatus.notVerified:
        return _buildCard(
          context,
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.textSecondary,
          title: 'Not Verified',
          subtitle: customSubtitle ?? 'Complete profile to request verification.',
          borderColor: Colors.white.withValues(alpha: 0.1),
          backgroundColor: Colors.white.withValues(alpha: 0.05),
        );
    }
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color borderColor,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                if ((status == VerificationStatus.notVerified || status == VerificationStatus.rejected) && onActionPressed != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onActionPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Complete Profile'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
