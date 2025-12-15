import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class ApplicantCard extends StatelessWidget {
  final Collaboration collaboration;

  const ApplicantCard({super.key, required this.collaboration});

  void _updateStatus(BuildContext context, String status) {
    context.read<CollaborationBloc>().add(
      UpdateCollaborationStatus(
        collaborationId: collaboration.id,
        status: status,
      ),
    );
    // Refresh strictly handled by Bloc listener or parent logic,
    // but here we just dispatch.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: collaboration.collaboratorAvatarUrl != null
                      ? NetworkImage(collaboration.collaboratorAvatarUrl!)
                      : null,
                  child: collaboration.collaboratorAvatarUrl == null
                      ? Text(collaboration.collaboratorName?[0] ?? 'C')
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        collaboration.collaboratorName ?? 'Unknown',
                        style: theme.textTheme.titleMedium,
                      ),
                      if (collaboration.collaboratorHeadline != null)
                        Text(
                          collaboration.collaboratorHeadline!,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(collaboration.roleApplied),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(collaboration.message, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              'Applied ${timeago.format(collaboration.appliedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (collaboration.status == 'Pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _updateStatus(context, 'Rejected'),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _updateStatus(context, 'Accepted'),
                    child: const Text('Accept'),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  collaboration.status,
                  style: TextStyle(
                    color: collaboration.status == 'Accepted'
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
