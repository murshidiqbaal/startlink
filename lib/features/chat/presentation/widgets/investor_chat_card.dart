import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/presentation/bloc/innovator_chat_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

class InvestorChatCard extends StatelessWidget {
  final InvestorChatItem item;
  final VoidCallback onTap;

  const InvestorChatCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceGlass,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: onTap,
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.brandPurple.withValues(alpha: 0.1),
          backgroundImage: item.avatarUrl != null ? NetworkImage(item.avatarUrl!) : null,
          child: item.avatarUrl == null ? const Icon(Icons.person, color: AppColors.brandPurple) : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                item.investorName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'INVESTOR',
                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.ideaTitle,
              style: const TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.lastMessage,
              style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Text(
          timeago.format(item.timestamp, locale: 'en_short'),
          style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 11),
        ),
      ),
    );
  }
}
