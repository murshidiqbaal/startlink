import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/home/presentation/bloc/mentor_home_bloc.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/profile/presentation/mentor_profile_screen.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const MentorHome(), const MentorProfileScreen()];

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
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Mentorship',
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

class MentorHome extends StatelessWidget {
  const MentorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MentorHomeBloc(ideaRepository: context.read<IdeaRepository>())
            ..add(FetchMentorFeed()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mentor Panel'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          ],
        ),
        body: BlocBuilder<MentorHomeBloc, MentorHomeState>(
          builder: (context, state) {
            if (state is MentorHomeLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is MentorHomeLoaded) {
              if (state.ideas.isEmpty) {
                return const Center(
                  child: Text('No ideas ready for mentorship yet.'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<MentorHomeBloc>().add(FetchMentorFeed());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.ideas
                      .where((i) => i.status == 'Published')
                      .length,
                  itemBuilder: (context, index) {
                    final idea = state.ideas
                        .where((i) => i.status == 'Published')
                        .toList()[index];
                    return IdeaCard(
                      title: idea.title,
                      description: idea.description,
                      status: idea.status,
                      skills: idea.tags, // assuming tags are skills for now
                      views: idea.viewCount,
                      applications: idea.applicationCount,
                      aiQualityScore: idea.aiQualityScore?.toInt(),
                      isVerified: idea.isVerified,
                      onTap: () {
                        // Navigate to detail
                      },
                      onApply: () {
                        // "Offer Mentorship" logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mentorship request sent!'),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            } else if (state is MentorHomeError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
