import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/core/theme/app_theme.dart';
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
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Verification Dashboard'),
            centerTitle: true,
            bottom: TabBar(
              indicatorColor: AppColors.brandPurple,
              labelColor: AppColors.brandPurple,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: const [
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
          ),
          body: BlocConsumer<AdminVerificationBloc, AdminVerificationState>(
            listener: (context, state) {
              if (state is AdminVerificationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: AppColors.rose),
                );
              }
            },
            builder: (context, state) {
              if (state is AdminVerificationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is AdminVerificationLoaded) {
                return TabBarView(
                  children: [
                    _VerificationList(
                      verifications: state.pending,
                      status: 'Pending',
                    ),
                    _VerificationList(
                      verifications: state.approved,
                      status: 'Approved',
                    ),
                    _VerificationList(
                      verifications: state.rejected,
                      status: 'Rejected',
                    ),
                  ],
                );
              }
              return const Center(child: Text('Something went wrong'));
            },
          ),
        ),
      ),
    );
  }
}

class _VerificationList extends StatelessWidget {
  final List<UserVerification> verifications;
  final String status;

  const _VerificationList({
    required this.verifications,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (verifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No $status requests',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: verifications.length,
      itemBuilder: (context, index) {
        final item = verifications[index];
        return _VerificationCard(item: item);
      },
    );
  }
}

class _VerificationCard extends StatelessWidget {
  final UserVerification item;

  const _VerificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(item.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.brandPurple.withOpacity(0.1),
                  child: Text(
                    (item.fullName ?? item.role)[0].toUpperCase(),
                    style: const TextStyle(color: AppColors.brandPurple, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fullName ?? 'Unknown User',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        item.email ?? 'No email provided',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: item.status, color: color),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white12),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoItem(label: 'Role', value: item.role.toUpperCase(), icon: Icons.work_outline),
                _InfoItem(
                  label: 'Submitted',
                  value: DateFormat('MMM d, yyyy').format(item.createdAt),
                  icon: Icons.calendar_today_outlined,
                ),
              ],
            ),
            if (item.status == 'Pending') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rose,
                        side: const BorderSide(color: AppColors.rose),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => context.read<AdminVerificationBloc>().add(
                            ApproveRequest(item.id, item.profileId),
                          ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return AppColors.emerald;
      case 'Rejected':
        return AppColors.rose;
      default:
        return AppColors.amber;
    }
  }

  void _showRejectDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            hintText: 'e.g. Incomplete profile',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminVerificationBloc>().add(
                    RejectRequest(item.id, controller.text),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose),
            child: const Text('Reject User'),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }
}
