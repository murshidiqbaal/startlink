import 'package:flutter/material.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration.dart';
import 'package:timeago/timeago.dart' as timeago;

class CollaborationCard extends StatelessWidget {
  final Collaboration collaboration;

  const CollaborationCard({super.key, required this.collaboration});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    IconData statusIcon;

    switch (collaboration.status) {
      case 'Accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          collaboration.ideaTitle ?? 'Unknown Idea',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Role: ${collaboration.roleApplied}'),
            const SizedBox(height: 4),
            Text(
              'Applied ${timeago.format(collaboration.appliedAt)}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text(
                collaboration.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
