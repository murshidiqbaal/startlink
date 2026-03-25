import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class MyCollaborationsScreen extends StatefulWidget {
  const MyCollaborationsScreen({super.key});

  @override
  State<MyCollaborationsScreen> createState() => _MyCollaborationsScreenState();
}

class _MyCollaborationsScreenState extends State<MyCollaborationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollaborationBloc>().add(FetchMyCollaborations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Applications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CollaborationBloc, CollaborationState>(
        builder: (context, state) {
          if (state is CollaborationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brandCyan));
          }
          
          if (state is CollaborationError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.rose),
                textAlign: TextAlign.center,
              ),
            );
          }

          if (state is CollaborationLoaded) {
            if (state.applications.isEmpty) {
              return const Center(
                child: Text(
                  'You have not applied to any ideas yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CollaborationBloc>().add(FetchMyCollaborations());
              },
              color: AppColors.brandCyan,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _MyCollaborationCard(request: state.applications[index]);
                },
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class _MyCollaborationCard extends StatelessWidget {
  final CollaborationRequest request;

  const _MyCollaborationCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final innovator = request.innovator ?? {};
    final fullName = innovator['full_name'] ?? 'Unknown Innovator';
    final avatarUrl = innovator['avatar_url'] as String?;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.ideaTitle ?? 'Unknown Idea',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.brandCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _StatusIndicator(status: request.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white.withOpacity(0.1),
                backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: (avatarUrl == null || avatarUrl.isEmpty)
                    ? const Icon(Icons.person, color: AppColors.textSecondary, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'Innovator: $fullName',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Role: ${request.roleApplied}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Applied ${timeago.format(request.createdAt)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (request.status == 'accepted') ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'Check your Chat tab to collaborate!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (status.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = AppColors.rose;
        break;
      case 'pending':
      default:
        color = AppColors.brandPurple;
        break;
    }

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          status.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
