import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class VerificationStatusCard extends StatelessWidget {
  final String status;
  final String role;
  final VoidCallback? onActionPressed;

  const VerificationStatusCard({
    super.key,
    required this.status,
    required this.role,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case 'Approved':
        return _buildStatusContainer(
          context,
          icon: Icons.verified,
          color: AppColors.emerald,
          label: '✔ Verified ${role[0].toUpperCase()}${role.substring(1)}',
          description: null,
        );
      case 'Pending':
        return _buildStatusContainer(
          context,
          icon: Icons.hourglass_top,
          color: AppColors.amber,
          label: '⏳ Verification Pending',
          description: 'Your profile is under review by Startlink admin.',
        );
      case 'Rejected':
        return _buildStatusContainer(
          context,
          icon: Icons.error_outline,
          color: AppColors.rose,
          label: '⚠ Verification Rejected',
          description: 'Please update your profile and try again.',
          actionLabel: 'Update Profile',
        );
      default:
        return _buildStatusContainer(
          context,
          icon: Icons.info_outline,
          color: AppColors.rose,
          label: '⚠ Profile Not Verified',
          description: 'Complete your profile to request verification.',
          actionLabel: 'Complete Profile',
        );
    }
  }

  Widget _buildStatusContainer(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    String? description,
    String? actionLabel,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
          if (actionLabel != null && onActionPressed != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
