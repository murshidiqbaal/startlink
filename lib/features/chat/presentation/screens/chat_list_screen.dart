// lib/features/chat/presentation/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/investor/data/models/investor_chat_model.dart';
import 'package:startlink/features/investor/presentation/pages/investor_chat_screen.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../bloc/chat_list_bloc.dart';
import '../bloc/chat_list_event.dart';
import '../bloc/chat_list_state.dart';
import '../bloc/innovator_chat_bloc.dart';
import '../widgets/chat_room_card.dart';
import '../widgets/investor_chat_card.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  RealtimeChannel? _investorChannel;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRooms();
      _subscribeToInvestorChats();
    });
  }

  @override
  void dispose() {
    _investorChannel?.unsubscribe();
    super.dispose();
  }

  void _subscribeToInvestorChats() {
    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId == null) return;

    _investorChannel = SupabaseService.client
        .channel('public:investor_messages_innovator_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'investor_messages',
          callback: (payload) {
            if (mounted) {
              context.read<InnovatorChatBloc>().add(
                RefreshInnovatorInvestorChats(userId),
              );
            }
          },
        )
        .subscribe();
  }

  void _loadRooms() {
    final profileBloc = context.read<RoleProfileBloc>();
    final profileState = profileBloc.state;

    if (profileState is RoleProfileLoaded) {
      final role = profileState.baseProfile.role;
      if (role == 'innovator') {
        context.read<ChatListBloc>().add(LoadInnovatorTeams());
        final userId = context.read<AuthRepository>().currentUser?.id;
        if (userId != null) {
          context.read<InnovatorChatBloc>().add(
            LoadInnovatorInvestorChats(userId),
          );
        }
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
        title: const Text(
          "Messages",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, teamState) {
          return BlocBuilder<InnovatorChatBloc, InnovatorChatState>(
            builder: (context, investorState) {
              if (teamState is ChatListLoading ||
                  investorState is InnovatorChatsLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandPurple,
                  ),
                );
              }

              final teams = (teamState is ChatListLoaded)
                  ? teamState.teams
                  : [];
              final investorChats = (investorState is InnovatorChatsLoaded)
                  ? investorState.investorChats
                  : [];

              if (teams.isEmpty && investorChats.isEmpty) {
                return _buildEmptyState();
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (investorChats.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        "INVESTOR CONVERSATIONS",
                        style: TextStyle(
                          color: AppColors.brandPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...investorChats.map(
                      (chat) => InvestorChatCard(
                        item: chat,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvestorChatScreen(
                              chat: InvestorChatModel(
                                id: chat.chatId,
                                ideaId:
                                    '', // These will be refetched in chat screen anyway
                                investorId: '',
                                innovatorId: '',
                                ideaTitle: chat.ideaTitle,
                                innovatorName: '',
                                investorName: chat.investorName,
                                investorAvatarUrl: chat.avatarUrl,
                                createdAt: chat.timestamp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (teams.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        "TEAM COLLABORATIONS",
                        style: TextStyle(
                          color: AppColors.brandPurple,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    ...teams.map(
                      (room) => ChatRoomCard(
                        ideaId: room.ideaId,
                        ideaTitle: room.name,
                        groupId: room.id,
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            "No active chats yet",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Chats appear when collaboration starts.",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
