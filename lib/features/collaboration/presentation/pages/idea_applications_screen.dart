import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/features/collaboration/domain/entities/collaboration_request.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';

class IdeaApplicationsScreen extends StatefulWidget {
  final String ideaId;
  final String ideaTitle;

  const IdeaApplicationsScreen({
    super.key,
    required this.ideaId,
    required this.ideaTitle,
  });

  @override
  State<IdeaApplicationsScreen> createState() => _IdeaApplicationsScreenState();
}

class _IdeaApplicationsScreenState extends State<IdeaApplicationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollaborationBloc>().add(LoadIdeaApplications(widget.ideaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Applications: ${widget.ideaTitle}'),
      ),
      body: BlocConsumer<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          if (state is CollaborationActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Reload applications after action
            context.read<CollaborationBloc>().add(LoadIdeaApplications(widget.ideaId));
          } else if (state is CollaborationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CollaborationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollaborationLoaded) {
            final applications = state.applications;
            if (applications.isEmpty) {
              return const Center(
                child: Text('No applications yet for this idea.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final request = applications[index];
                return _ApplicationCard(request: request);
              },
            );
          } else if (state is CollaborationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () => context
                        .read<CollaborationBloc>()
                        .add(LoadIdeaApplications(widget.ideaId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final CollaborationRequest request;

  const _ApplicationCard({required this.request});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: request.applicant?['avatar_url'] != null
                      ? NetworkImage(request.applicant!['avatar_url'])
                      : null,
                  child: request.applicant?['avatar_url'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.applicant?['full_name'] ?? 'Unknown Applicant',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Role: ${request.roleApplied}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor(request.status)),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(request.status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const Text(
                'Message:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.message!),
              const SizedBox(height: 12),
            ],
            Text(
              'Applied on: ${DateFormat('MMM dd, yyyy').format(request.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (request.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      context
                          .read<CollaborationBloc>()
                          .add(RejectCollaborationRequest(request.id));
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<CollaborationBloc>()
                          .add(AcceptCollaborationRequest(request.id));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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
