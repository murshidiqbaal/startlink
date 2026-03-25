import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import '../bloc/collaboration_chat_bloc.dart';
import '../bloc/collaboration_chat_event.dart';
import '../bloc/collaboration_chat_state.dart';
import '../widgets/collaboration_chat_card.dart';

class CollaborationChatListScreen extends StatefulWidget {
  final bool isInnovator;

  const CollaborationChatListScreen({
    super.key,
    required this.isInnovator,
  });

  @override
  State<CollaborationChatListScreen> createState() => _CollaborationChatListScreenState();
}

class _CollaborationChatListScreenState extends State<CollaborationChatListScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.isInnovator) {
      context.read<CollaborationChatBloc>().add(LoadInnovatorChats());
    } else {
      context.read<CollaborationChatBloc>().add(LoadCollaboratorChats());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Relies on dashboard background if inside index stack
      body: BlocBuilder<CollaborationChatBloc, CollaborationChatState>(
        builder: (context, state) {
          if (state is CollaborationChatInitial || state is CollaborationChatLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            );
          } else if (state is CollaborationChatError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.rose),
                ),
              ),
            );
          } else if (state is CollaborationChatLoaded) {
            if (state.chats.isEmpty) {
              return _buildEmptyState();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ListView.builder(
                itemCount: state.chats.length,
                itemBuilder: (context, index) {
                  final chat = state.chats[index];
                    return CollaborationChatCard(
                      ideaId: chat.ideaId,
                      ideaTitle: chat.ideaTitle,
                      partnerName: chat.partnerName,
                      avatar: chat.partnerAvatar,
                      groupId: chat.roomId, // If the model still uses roomId, we map it to groupId here
                    );
                },
              ),
            );
          }
          return const SizedBox.shrink();
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
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            widget.isInnovator
                ? 'No active collaborations yet.'
                : 'You have not joined any ideas yet.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
