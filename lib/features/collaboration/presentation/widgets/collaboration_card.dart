import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:timeago/timeago.dart' as timeago;

class CollaborationCard extends StatelessWidget {
  final CollaborationRequest request;

  const CollaborationCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    IconData statusIcon;

    final status = request.status.toLowerCase();
    if (status == 'accepted') {
      statusColor = AppColors.emerald;
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'rejected') {
      statusColor = AppColors.rose;
      statusIcon = Icons.highlight_off;
    } else {
      statusColor = AppColors.amber;
      statusIcon = Icons.auto_awesome;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: StartLinkGlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.ideaTitle ?? 'Unknown Idea',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        request.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                request.roleApplied,
                style: const TextStyle(
                  color: AppColors.brandPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (request.message != null && request.message!.isNotEmpty)
              Text(
                request.message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Applied ${timeago.format(request.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
