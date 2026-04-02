import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/home/presentation/bloc/mentor_home_bloc.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/mentor/domain/repositories/mentor_chat_repository.dart';
import 'package:startlink/features/mentor/presentation/pages/mentor_chat_list_screen.dart';
import 'package:startlink/features/mentor/presentation/pages/mentor_chat_room_screen.dart';
import 'package:startlink/features/mentor/presentation/pages/mentor_management_screen.dart';
import 'package:startlink/features/mentor/presentation/pages/mentor_reels_screen.dart';
import 'package:startlink/features/profile/presentation/mentor_profile_screen.dart';
import 'package:startlink/features/verification/presentation/widgets/role_verification_guard.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const MentorHome(),
    const MentorChatListScreen(),
    const MentorReelsScreen(),
    const MentorManagementScreen(),
    const MentorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoleVerificationGuard(
        role: 'mentor',
        child: _pages[_selectedIndex],
      ),
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
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: 'Manage',
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
                      imageUrl: idea.coverImageUrl,
                      onTap: () {
                        // Navigate to detail
                      },
                      onApply: () async {
                        final mentorId = context.read<AuthRepository>().currentUser?.id;
                        if (mentorId == null) return;
                        
                        final chatRepo = context.read<IMentorChatRepository>();
                        try {
                          final chat = await chatRepo.createOrFetchChat(
                            mentorId,
                            idea.ownerId,
                            idea.id,
                          );
                          
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MentorChatRoomScreen(chat: chat),
                              ),
                            );
                          }
                        } catch (e) {
                           if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error starting chat: $e')),
                            );
                          }
                        }
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
