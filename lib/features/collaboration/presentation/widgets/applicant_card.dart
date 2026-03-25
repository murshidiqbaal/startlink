import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ApplicantCard extends StatelessWidget {
  final CollaborationRequest request;

  const ApplicantCard({super.key, required this.request});

  void _updateStatus(BuildContext context, String status) {
    context.read<CollaborationBloc>().add(
      UpdateCollaborationStatus(
        collaborationId: request.id,
        status: status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final applicant = request.applicant ?? {};

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (request.applicantId.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              userId: request.applicantId,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              applicant['avatar_url'] != null
                              ? NetworkImage(
                                  applicant['avatar_url']!,
                                )
                              : null,
                          child: applicant['avatar_url'] == null
                              ? Text(applicant['full_name']?[0] ?? 'A')
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                applicant['full_name'] ?? 'Unknown',
                                style: theme.textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (applicant['headline'] != null)
                                Text(
                                  applicant['headline']!,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    request.roleApplied,
                    overflow: TextOverflow.ellipsis,
                  ),
                  backgroundColor: theme.colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(request.message ?? '', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              'Applied ${timeago.format(request.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (request.status.toLowerCase() == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _updateStatus(context, 'rejected'),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _updateStatus(context, 'accepted'),
                    child: const Text('Accept'),
                  ),
                ],
              )
            else
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  request.status.toUpperCase(),
                  style: TextStyle(
                    color: request.status.toLowerCase() == 'accepted'
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
