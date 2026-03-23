import 'package:flutter/material.dart';

class InvestorIdeaCard extends StatelessWidget {
  final String title;
  final String? aiSummary;
  final String stage;
  final String targetMarket;
  final List<String> skills;
  final bool isBoosted;
  final bool isVerified;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onExpressInterest;
  final bool isBookmarked;
  final bool isInterested;
  final String? imageUrl;

  const InvestorIdeaCard({
    super.key,
    required this.title,
    this.aiSummary,
    required this.stage,
    required this.targetMarket,
    required this.skills,
    this.isBoosted = false,
    this.isVerified = false,
    required this.onTap,
    required this.onBookmark,
    required this.onExpressInterest,
    this.isBookmarked = false,
    this.isInterested = false,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isBoosted
              ? Colors.amber.withOpacity(0.5)
              : Theme.of(context).colorScheme.outline.withOpacity(0.1),
          width: isBoosted ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // Header: Boosted + Verified + Title
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isBoosted) ...[
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (isVerified) ...[
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // AI Summary
              if (aiSummary != null && aiSummary!.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          aiSummary!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tags: Stage, Market
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildChip(context, stage, Icons.timeline),
                  _buildChip(context, targetMarket, Icons.public),
                ],
              ),
              const SizedBox(height: 8),

              // Skills
              if (skills.isNotEmpty)
                Text(
                  'Needs: ${skills.take(3).join(', ')}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              const SizedBox(height: 8),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onBookmark,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      size: 18,
                    ),
                    label: const Text('Save'),
                    style: TextButton.styleFrom(
                      foregroundColor: isBookmarked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onExpressInterest,
                    icon: Icon(
                      isInterested ? Icons.check : Icons.thumb_up_outlined,
                      size: 18,
                    ),
                    label: Text(
                      isInterested ? 'Interested' : 'Express Interest',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isInterested
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
