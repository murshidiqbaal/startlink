import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/presentation/widgets/anti_gravity/floating_widget.dart';
import '../../domain/entities/team_message.dart';

class PremiumChatBubble extends StatelessWidget {
  final TeamMessage message;
  final bool isMe;
  final bool showAvatar;

  const PremiumChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar) ...[
            _buildAvatar(message.senderName ?? '?', message.senderAvatar),
            const SizedBox(width: 8),
          ] else if (!isMe)
            const SizedBox(width: 40),
            
          Flexible(
            child: FloatingWidget(
              intensity: 1.5,
              duration: const Duration(seconds: 5),
              isReverse: isMe,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isMe 
                        ? AppColors.brandPurple.withValues(alpha: 0.25)
                        : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                      ),
                      border: Border.all(
                        color: isMe 
                          ? AppColors.brandPurple.withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.15),
                      ),
                      gradient: isMe ? LinearGradient(
                        colors: [
                          AppColors.brandPurple.withValues(alpha: 0.3),
                          AppColors.brandPurple.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isMe && message.senderName != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              message.senderName!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.brandCyan,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        Text(
                          message.content,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(message.createdAt),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isMe && showAvatar) ...[
            const SizedBox(width: 8),
            _buildAvatar('Me', null, isMe: true),
          ] else if (isMe)
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, String? imageUrl, {bool isMe = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isMe ? AppColors.startLinkGradient : null,
        color: isMe ? null : AppColors.brandPurple.withValues(alpha: 0.2),
        border: Border.all(
          color: isMe ? Colors.white38 : Colors.white24,
          width: 1,
        ),
        boxShadow: isMe ? [
          BoxShadow(
            color: AppColors.brandPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : null,
      ),
      child: Center(
        child: imageUrl != null 
          ? ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover))
          : Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
      ),
    );
  }

  String _formatTime(DateTime time) =>
      "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
}
