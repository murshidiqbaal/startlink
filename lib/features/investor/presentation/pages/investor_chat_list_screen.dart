import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_chat_bloc.dart';
import 'package:startlink/features/investor/presentation/pages/investor_chat_screen.dart';

class InvestorChatListScreen extends StatelessWidget {
  const InvestorChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestorChatBloc, InvestorChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }

        if (state is ChatsLoaded) {
          if (state.chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  const Text('No active conversations', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.chats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final chat = state.chats[index];
              return _buildChatTile(context, chat);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChatTile(BuildContext context, dynamic chat) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.brandPurple.withValues(alpha: 0.2),
          backgroundImage: chat.innovatorAvatarUrl != null ? NetworkImage(chat.innovatorAvatarUrl!) : null,
          child: chat.innovatorAvatarUrl == null ? Text(chat.innovatorName?[0] ?? '?', style: const TextStyle(color: Colors.white)) : null,
        ),
        title: Text(chat.innovatorName ?? 'Innovator', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(chat.ideaTitle ?? 'Idea Details', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InvestorChatScreen(chat: chat)),
        ),
      ),
    );
  }
}
