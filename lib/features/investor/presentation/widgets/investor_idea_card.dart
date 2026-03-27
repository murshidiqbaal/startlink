import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class InvestorIdeaCard extends StatelessWidget {
  final String title;
  final String? aiSummary;
  final String stage;
  final String targetMarket;
  final String? imageUrl;
  final bool isVerified;
  final VoidCallback onTap;

  const InvestorIdeaCard({
    super.key,
    required this.title,
    this.aiSummary,
    required this.stage,
    required this.targetMarket,
    this.imageUrl,
    this.isVerified = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.network(
                  imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.brandPurple.withValues(alpha: 0.1),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    child: Row(
                      children: [
                        _buildMiniTag(
                          stage.toUpperCase(),
                          AppColors.brandPurple,
                        ),
                        const SizedBox(width: 8),
                        _buildMiniTag(
                          targetMarket.toUpperCase(),
                          AppColors.textSecondary,
                        ),
                        const Spacer(),
                        if (isVerified)
                          const Icon(
                            Icons.verified,
                            color: AppColors.emerald,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (aiSummary != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      aiSummary!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'View Details',
                        style: TextStyle(
                          color: AppColors.brandPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.brandPurple,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
