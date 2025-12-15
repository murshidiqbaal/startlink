import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:startlink/features/collaboration/presentation/pages/collaboration_screen.dart';
import 'package:startlink/features/home/presentation/widgets/empty_state.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/home/presentation/widgets/stats_card.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/idea/presentation/idea_post_screen.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_profile_screen.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

class InnovatorDashboard extends StatefulWidget {
  const InnovatorDashboard({super.key});

  @override
  State<InnovatorDashboard> createState() => _InnovatorDashboardState();
}

class _InnovatorDashboardState extends State<InnovatorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InnovatorHome(),
    const CollaborationScreen(), // Added CollaborationScreen
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: RoleAwareNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_history_outlined),
            selectedIcon: Icon(Icons.work_history),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class InnovatorHome extends StatelessWidget {
  const InnovatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<IdeaBloc, IdeaState>(
        builder: (context, state) {
          // Trigger refresh on load if needed, or rely on App provider loading it
          return RefreshIndicator(
            onRefresh: () async {
              context.read<IdeaBloc>().add(RefreshIdeas());
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 120.0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: Text(
                            'JD', // Future: Get initials from User
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                    fontSize: 10,
                                  ),
                            ),
                            const Text(
                              'Innovator',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                            Theme.of(context).colorScheme.surface,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {},
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick Stats Row
                        Row(
                          children: [
                            StatsCard(
                              label: 'Total Ideas',
                              value: state is IdeaLoaded
                                  ? state.ideas.length.toString()
                                  : '-',
                              icon: Icons.lightbulb_outline,
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            StatsCard(
                              label: 'Collaborators',
                              value: '17', // Future: Dynamic
                              icon: Icons.group_outlined,
                              iconColor: Colors.orange,
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            StatsCard(
                              label: 'Reviews',
                              value: '4.8', // Future: Dynamic
                              icon: Icons.star_outline,
                              iconColor: Colors.yellow,
                              onTap: () {},
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Primary CTA
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              final profileState = context
                                  .read<ProfileBloc>()
                                  .state;
                              if (profileState is ProfileLoaded) {
                                if (profileState.profile.profileCompletion >=
                                    70) {
                                  // Navigate to Post Idea
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const IdeaPostScreen(),
                                    ),
                                  ).then((result) {
                                    // If result is true (idea posted), refresh the list
                                    if (result == true) {
                                      context.read<IdeaBloc>().add(
                                        RefreshIdeas(),
                                      );
                                    }
                                  });
                                } else {
                                  // Show Gate Modal
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.rocket_launch,
                                            size: 60,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Complete your profile to post ideas 🚀',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Your profile is ${profileState.profile.profileCompletion}% complete.\nAdd details to reach 70%.',
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfileScreen(
                                                          profile: profileState
                                                              .profile,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Complete Profile',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please wait, loading profile...',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add),
                                SizedBox(width: 8),
                                Text(
                                  'Post New Idea',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Ideas List Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Ideas',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                // Data States
                if (state is IdeaLoading)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Shimmer.fromColors(
                          baseColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          highlightColor: Theme.of(context).colorScheme.surface,
                          child: Container(
                            height: 120,
                            margin: const EdgeInsets.only(bottom: 16),
                            color: Colors.white,
                          ),
                        );
                      }, childCount: 3),
                    ),
                  )
                else if (state is IdeaError)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  )
                else if (state is IdeaLoaded)
                  if (state.ideas.isEmpty)
                    SliverToBoxAdapter(
                      child: EmptyState(
                        message:
                            "You haven't posted any ideas yet.\nShare your vision with the world!",
                        actionLabel: 'Post your first idea',
                        onAction: () {},
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final idea = state.ideas[index];
                          return IdeaCard(
                            title: idea.title,
                            description: idea.description,
                            status: idea.status,
                            skills: idea.tags,
                            views: 0, // Future: Backend
                            applications: 0, // Future: Backend
                            onTap: () {},
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IdeaPostScreen(idea: idea),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  context.read<IdeaBloc>().add(RefreshIdeas());
                                }
                              });
                            },
                          );
                        }, childCount: state.ideas.length),
                      ),
                    ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ), // Bottom padding for FAB if needed
              ],
            ),
          );
        },
      ),
    );
  }
}
