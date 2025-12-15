import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: AppBar(
        title: Text(
          _role == 'Innovator' ? 'Manage Applications' : 'My Collaborations',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'), // Accepted/Rejected
          ],
        ),
      ),
      body: BlocConsumer<CollaborationBloc, CollaborationState>(
        listener: (context, state) {
          if (state is CollaborationActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            _fetchData(); // Refresh list after action
          }
        },
        builder: (context, state) {
          if (state is CollaborationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CollaborationLoaded) {
            final pending = state.collaborations
                .where((c) => c.status == 'Pending')
                .toList();
            final history = state.collaborations
                .where((c) => c.status != 'Pending')
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildList(pending, isInnovator: _role == 'Innovator'),
                _buildList(history, isInnovator: _role == 'Innovator'),
              ],
            );
          } else if (state is CollaborationError) {
            return Center(child: Text(state.message));
          }
          // Fallback for empty state or partial loads handled by _buildList if list is empty
          // But if state is not Loaded yet (e.g. Initial), logic above handles loading/error
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List<dynamic> items, {required bool isInnovator}) {
    if (items.isEmpty) {
      return const Center(child: Text('No items to display'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (isInnovator) {
          return ApplicantCard(collaboration: item);
        } else {
          return CollaborationCard(collaboration: item);
        }
      },
    );
  }
}
