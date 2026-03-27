import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_list_event.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_list_state.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/glass_card.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_widget.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/presentation/screens/idea_docket_screen.dart';

import 'package:startlink/features/profile/presentation/bloc/role_profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';

class IdeaInboxScreen extends StatefulWidget {
  const IdeaInboxScreen({super.key});

  @override
  State<IdeaInboxScreen> createState() => _IdeaInboxScreenState();
}

class _IdeaInboxScreenState extends State<IdeaInboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChats();
    });
  }

  void _loadChats() {
    final profileBloc = context.read<RoleProfileBloc>();
    final profileState = profileBloc.state;
    
    if (profileState is RoleProfileLoaded) {
      final role = profileState.baseProfile.role?.toLowerCase();
      if (role == 'innovator') {
        context.read<ChatListBloc>().add(LoadInnovatorTeams());
      } else {
        context.read<ChatListBloc>().add(LoadCollaboratorTeams());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Idea Dockets',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadChats,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          if (state is ChatListLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          }
          if (state is ChatListError) {
            return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.redAccent)));
          }
          if (state is ChatListLoaded) {
            final teams = state.teams;
            if (teams.isEmpty) {
              return const Center(
                child: Text(
                  "No active idea dockets yet.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: FloatingWidget(
                    intensity: 3.0,
                    duration: Duration(seconds: 4 + index),
                    child: GlassCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => IdeaDocketScreen(
                              teamId: team.id,
                              ideaTitle: team.name,
                            ),
                          ),
                        );
                      },
                      height: 100,
                      borderColor: Colors.white.withValues(alpha: 0.1),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                team.name.isNotEmpty ? team.name[0] : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  team.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  "Tap to open team docket",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}


