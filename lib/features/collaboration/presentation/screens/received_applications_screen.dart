import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/core/presentation/widgets/startlink_button.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReceivedApplicationsScreen extends StatefulWidget {
  const ReceivedApplicationsScreen({super.key});

  @override
  State<ReceivedApplicationsScreen> createState() => _ReceivedApplicationsScreenState();
}

class _ReceivedApplicationsScreenState extends State<ReceivedApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollaborationBloc>().add(FetchReceivedCollaborations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Received Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocConsumer<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          if (state is CollaborationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh list
            context.read<CollaborationBloc>().add(FetchReceivedCollaborations());
          } else if (state is CollaborationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CollaborationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
          }

          if (state is CollaborationLoaded) {
            if (state.applications.isEmpty) {
              return const Center(
                child: Text(
                  'No applications received yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CollaborationBloc>().add(FetchReceivedCollaborations());
              },
              color: AppColors.brandPurple,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _ApplicationCard(request: state.applications[index]);
                },
              ),
            );
          }

          return const Center(
            child: Text(
              'Something went wrong.',
              style: TextStyle(color: AppColors.rose),
            ),
          );
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final CollaborationRequest request;

  const _ApplicationCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final applicant = request.applicant ?? {};
    final fullName = applicant['full_name'] ?? 'Unknown User';
    final avatarUrl = applicant['avatar_url'] as String?;
    final headline = applicant['headline'] as String? ?? 'No headline provided';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: AppColors.textSecondary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      headline,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: request.status),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(request.createdAt),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Idea: ${request.ideaTitle ?? 'Unknown Idea'}',
            style: const TextStyle(
              color: AppColors.brandCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Role: ${request.roleApplied}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (request.message != null && request.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${request.message}"',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          if (request.status == 'pending') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<CollaborationBloc>().add(
                        RejectCollaborationRequest(request.id),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.rose,
                      side: const BorderSide(color: AppColors.rose),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StartLinkButton(
                    label: 'Accept',
                    onPressed: () {
                      context.read<CollaborationBloc>().add(
                        AcceptCollaborationRequest(request.id),
                      );
                    },
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'accepted':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green;
        break;
      case 'rejected':
        bgColor = AppColors.rose.withOpacity(0.2);
        textColor = AppColors.rose;
        break;
      case 'pending':
      default:
        bgColor = AppColors.brandPurple.withOpacity(0.2);
        textColor = AppColors.brandPurple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
