import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/collaboration/presentation/pages/collaboration_screen.dart';
import 'package:startlink/features/collaboration/presentation/widgets/apply_collaboration_dialog.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

class CollaboratorDashboard extends StatefulWidget {
  const CollaboratorDashboard({super.key});

  @override
  State<CollaboratorDashboard> createState() => _CollaboratorDashboardState();
}

class _CollaboratorDashboardState extends State<CollaboratorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CollaboratorHome(),
    const CollaborationScreen(), // Collaborations
    const Center(child: Text('Messages Coming Soon')),
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
          NavigationDestination(icon: Icon(Icons.message), label: 'Messages'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class CollaboratorHome extends StatefulWidget {
  const CollaboratorHome({super.key});

  @override
  State<CollaboratorHome> createState() => _CollaboratorHomeState();
}

class _CollaboratorHomeState extends State<CollaboratorHome> {
  @override
  void initState() {
    super.initState();
    // Ensure we have fresh data
    context.read<IdeaBloc>().add(FetchIdeas());
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
          } else if (state is IdeaLoaded) {
            if (state.ideas.isEmpty) {
              return const Center(
                child: Text('No ideas found to collaborate on.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.ideas.length,
              itemBuilder: (context, index) {
                final idea = state.ideas[index];
                return IdeaCard(
                  title: idea.title,
                  description: idea.description,
                  status: idea.status,
                  skills: idea.tags,
                  views: 120, // Placeholder
                  applications: 5, // Placeholder
                  onApply: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          ApplyCollaborationDialog(idea: idea),
                    );
                  },
                );
              },
            );
          } else if (state is IdeaError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Welcome to StartLink'));
        },
      ),
    );
  }
}
