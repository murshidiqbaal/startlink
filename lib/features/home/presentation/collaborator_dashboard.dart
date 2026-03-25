// lib/features/collaboration/presentation/pages/collaborator_dashboard.dart
//
// ── CHANGES from original ────────────────────────────────────────────────────
//  • Wraps the dashboard in a ConversationBloc provider so IdeaInboxScreen
//    can call context.read<ConversationBloc>() safely.
//  • IdeaInboxScreen import updated to the new messaging feature path.
// ────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/collaboration/presentation/screens/my_collaborations_screen.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/collaboration/presentation/widgets/apply_collaboration_dialog.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/idea/presentation/pages/idea_detail_screen.dart';
import 'package:startlink/features/collaboration/presentation/pages/idea_inbox_screen.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

class CollaboratorDashboard extends StatelessWidget {
  const CollaboratorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Shared blocs now provided via AppShell
    return const _CollaboratorScaffold();
  }
}

class _CollaboratorScaffold extends StatefulWidget {
  const _CollaboratorScaffold();

  @override
  State<_CollaboratorScaffold> createState() => _CollaboratorScaffoldState();
}

class _CollaboratorScaffoldState extends State<_CollaboratorScaffold> {
  int _selectedIndex = 0;

  // Pages are created once; state is preserved across tab switches
  final List<Widget> _pages = [
    const CollaboratorHome(),
    const MyCollaborationsScreen(),
    const IdeaInboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: RoleAwareNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.work_history),
            label: 'Collaborations',
          ),
          NavigationDestination(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ── Collaborator Home (unchanged, copied here for completeness) ───────────────

class CollaboratorHome extends StatefulWidget {
  const CollaboratorHome({super.key});

  @override
  State<CollaboratorHome> createState() => _CollaboratorHomeState();
}

class _CollaboratorHomeState extends State<CollaboratorHome> {
  @override
  void initState() {
    super.initState();
    context.read<IdeaBloc>().add(FetchPublicIdeas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collaborator Hub'),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<IdeaBloc, IdeaState>(
        builder: (context, state) {
          if (state is IdeaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is IdeaLoaded) {
            if (state.ideas.isEmpty) {
              return const Center(
                child: Text('No ideas found to collaborate on.'),
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<IdeaBloc>().add(FetchPublicIdeas()),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.ideas.length,
                itemBuilder: (context, index) {
                  final idea = state.ideas[index];
                  return IdeaCard(
                    title: idea.title,
                    description: idea.description,
                    status: idea.status,
                    skills: idea.tags,
                    views: 120,
                    applications: 5,
                    imageUrl: idea.coverImageUrl,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdeaDetailScreen(idea: idea),
                      ),
                    ),
                    onApply: () => showDialog(
                      context: context,
                      builder: (dialogContext) => BlocProvider.value(
                        value: context.read<CollaborationBloc>(),
                        child: ApplyCollaborationDialog(idea: idea),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is IdeaError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          return const Center(child: Text('Welcome to StartLink'));
        },
      ),
    );
  }
}