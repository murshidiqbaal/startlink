import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/anti_gravity/glass_card.dart';
import '../../../../core/theme/app_theme.dart';

class PremiumChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hintText;

  const PremiumChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.hintText = 'Type a message...',
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 0,
      blur: 25,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSend(),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _buildSendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: onSend,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.startLinkGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPurple.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.send_rounded,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
