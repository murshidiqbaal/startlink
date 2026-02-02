import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/features/admin/data/repositories/admin_verification_repository_impl.dart';
import 'package:startlink/features/admin/presentation/bloc/admin_verification_bloc.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

class AdminVerificationDashboard extends StatelessWidget {
  const AdminVerificationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminVerificationBloc(repository: AdminVerificationRepositoryImpl())
            ..add(FetchRequests()),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Verification Center'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
                Tab(text: 'Approved', icon: Icon(Icons.check_circle_outline)),
                Tab(text: 'Rejected', icon: Icon(Icons.cancel_outlined)),
              ],
            ),
          ),
          body: BlocBuilder<AdminVerificationBloc, AdminVerificationState>(
            builder: (context, state) {
              if (state is AdminVerificationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminVerificationLoaded) {
                return TabBarView(
                  children: [
                    _VerificationList(
                      verifications: state.pending,
                      onApprove: (id, pid) => context
                          .read<AdminVerificationBloc>()
                          .add(ApproveRequest(id, pid)),
                      onReject: (id, reason) => context
                          .read<AdminVerificationBloc>()
                          .add(RejectRequest(id, reason)),
                      isPending: true,
                    ),
                    _VerificationList(
                      verifications: state.approved,
                      isPending: false,
                    ),
                    _VerificationList(
                      verifications: state.rejected,
                      isPending: false,
                    ),
                  ],
                );
              }
              if (state is AdminVerificationError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

class _VerificationList extends StatelessWidget {
  final List<UserVerification> verifications;
  final Function(String, String)? onApprove;
  final Function(String, String)? onReject;
  final bool isPending;

  const _VerificationList({
    required this.verifications,
    this.onApprove,
    this.onReject,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    if (verifications.isEmpty) {
      return const Center(child: Text('No requests found'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: verifications.length,
      itemBuilder: (context, index) {
        final item = verifications[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(child: Text(item.role[0])),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Profile ID: ...${item.profileId.substring(item.profileId.length - 6)}',
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.role} • ${item.verificationType}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d').format(item.createdAt),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                if (isPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () =>
                            _showRejectDialog(context, item.id), // Simplified
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () =>
                            onApprove?.call(item.id, item.profileId),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String id) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onReject?.call(id, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
