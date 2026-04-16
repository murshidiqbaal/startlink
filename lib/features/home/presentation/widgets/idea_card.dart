import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';

class IdeaCard extends StatelessWidget {
  final String title;
  final String description;
  final String status;
  final List<String> skills;
  final int views;
  final int applications;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onApply;
  final int? aiQualityScore;
  final bool isVerified;

  final String? imageUrl;

  const IdeaCard({
    super.key,
    required this.title,
    required this.description,
    required this.status,
    required this.skills,
    required this.views,
    required this.applications,
    this.imageUrl,
    this.onTap,
    this.onEdit,
    this.onApply,
    this.aiQualityScore,
    this.isVerified = false,
  });

  Color _getStatusColor(BuildContext context, String status) {
    final customColors = Theme.of(context).extension<StartLinkColors>();
    switch (status.toLowerCase()) {
      case 'open':
        return customColors?.signalEmerald ?? Colors.green;
      case 'in review':
        return customColors?.signalAmber ?? Colors.orange;
      case 'closed':
        return customColors?.signalRose ?? Colors.red;
      default:
        return AppColors.brandPurple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: StartLinkGlassCard(
        onTap: onTap,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    width: double.infinity,
                    color: AppColors.surfaceGlass,
                    child: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.brandBlue,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                      ),
                      onPressed: onEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  if (onApply != null)
                    FilledButton(
                      onPressed: onApply,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        textStyle: theme.textTheme.labelSmall,
                      ),
                      child: const Text('Apply'),
                    ),
                  if (onApply == null && onEdit == null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          context,
                          status,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(
                            context,
                            status,
                          ).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: _getStatusColor(context, status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.take(3).map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              child: Row(
                children: [
                  _buildStat(context, Icons.remove_red_eye_outlined, '$views'),
                  const SizedBox(width: 20),
                  Flexible(
                    fit: FlexFit.loose,
                    child: _buildStat(
                      context,
                      Icons.people_outline,
                      '$applications Applied',
                    ),
                  ),
                  if (aiQualityScore != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.startLinkGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$aiQualityScore',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
