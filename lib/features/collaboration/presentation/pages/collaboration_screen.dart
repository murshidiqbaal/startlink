import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/role_bloc.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/collaboration/presentation/widgets/applicant_card.dart';
import 'package:startlink/features/collaboration/presentation/widgets/collaboration_card.dart';

class CollaborationScreen extends StatefulWidget {
  const CollaborationScreen({super.key});

  @override
  State<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends State<CollaborationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final String _role;

  @override
  void initState() {
    super.initState();
    final roleState = context.read<RoleBloc>().state;
    _role = roleState.activeRole;
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  void _fetchData() {
    if (_role == 'Innovator') {
      context.read<CollaborationBloc>().add(FetchReceivedCollaborations());
    } else {
      context.read<CollaborationBloc>().add(FetchMyCollaborations());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _role == 'Innovator' ? 'Manage Applications' : 'My Collaborations',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandCyan,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.brandCyan,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: BlocConsumer<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          if (state is CollaborationActionSuccess ||
              state is CollaborationApplied) {
            String message = '';
            if (state is CollaborationActionSuccess) message = state.message;
            if (state is CollaborationApplied) message = state.message;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: AppColors.emerald,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            _fetchData();
          }
        },
        builder: (context, state) {
          if (state is CollaborationLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.brandCyan));
          } else if (state is CollaborationLoaded) {
            final pending = state.applications
                .where((c) => c.status.toLowerCase() == 'pending')
                .toList();
            final history = state.applications
                .where((c) => c.status.toLowerCase() != 'pending')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(
                  pending, 
                  isInnovator: _role == 'Innovator',
                  emptyMessage: _role == 'Innovator' 
                      ? 'No pending applications for your ideas.' 
                      : 'You haven\'t applied to any ideas yet.',
                  emptyIcon: Icons.hourglass_empty,
                ),
                _buildList(
                  history, 
                  isInnovator: _role == 'Innovator',
                  emptyMessage: 'No collaboration history found.',
                  emptyIcon: Icons.history,
                ),
              ],
            );
          } else if (state is CollaborationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.rose),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _fetchData, child: const Text('Retry')),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(
    List<dynamic> items, {
    required bool isInnovator,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: AppColors.textSecondary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (isInnovator) {
          return ApplicantCard(request: item);
        } else {
          return CollaborationCard(request: item);
        }
      },
    );
  }
}
