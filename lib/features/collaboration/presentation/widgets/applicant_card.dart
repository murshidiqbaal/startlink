import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
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
    final isPending = request.status.toLowerCase() == 'pending';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: StartLinkGlassCard(
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
                          radius: 20,
                          backgroundColor: AppColors.brandPurple.withValues(alpha: 0.1),
                          backgroundImage:
                              applicant['avatar_url'] != null
                              ? NetworkImage(
                                  applicant['avatar_url']!,
                                )
                              : null,
                          child: applicant['avatar_url'] == null
                              ? Text(
                                  applicant['full_name']?[0] ?? 'A',
                                  style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                applicant['full_name'] ?? 'Unknown',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (applicant['headline'] != null)
                                Text(
                                  applicant['headline']!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    request.roleApplied,
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                request.message!,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Applied ${timeago.format(request.createdAt)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (request.status.toLowerCase() == 'accepted' 
                          ? AppColors.emerald 
                          : AppColors.rose).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      request.status.toUpperCase(),
                      style: TextStyle(
                        color: request.status.toLowerCase() == 'accepted' 
                            ? AppColors.emerald 
                            : AppColors.rose,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _updateStatus(context, 'rejected'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rose,
                      side: const BorderSide(color: AppColors.rose),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _updateStatus(context, 'accepted'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.brandPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Accept'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
