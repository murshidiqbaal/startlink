// lib/features/chat/presentation/widgets/chat_room_card.dart
import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import '../screens/idea_workspace_screen.dart';

class ChatRoomCard extends StatelessWidget {
  final String ideaTitle;
  final String roomId;
  final String ideaId;

  const ChatRoomCard({
    super.key,
    required this.ideaTitle,
    required this.roomId,
    required this.ideaId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.surfaceGlass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.brandPurple.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            color: AppColors.brandPurple,
          ),
        ),
        title: Text(
          ideaTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          "Team Chat",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: const Icon(
          Icons.chat_bubble_outline,
          color: AppColors.brandCyan,
          size: 20,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IdeaWorkspaceScreen(
                ideaId: ideaId,
                roomId: roomId,
                ideaTitle: ideaTitle,
              ),
            ),
          );
        },
      ),
    );
  }
}
