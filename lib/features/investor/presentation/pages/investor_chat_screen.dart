import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/investor/domain/entities/investor_chat.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_chat_bloc.dart';

class InvestorChatScreen extends StatefulWidget {
  final InvestorChat chat;

  const InvestorChatScreen({super.key, required this.chat});

  @override
  State<InvestorChatScreen> createState() => _InvestorChatScreenState();
}

class _InvestorChatScreenState extends State<InvestorChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<InvestorChatBloc>().add(LoadChatMessages(widget.chat.id));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId == null) return;

    context.read<InvestorChatBloc>().add(SendInvestorMessage(
      chatId: widget.chat.id,
      senderId: userId,
      content: text,
    ));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chat.innovatorName ?? 'Chat', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.chat.ideaTitle ?? 'Investment Inquiry', style: const TextStyle(fontSize: 12, color: AppColors.brandPurple)),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<InvestorChatBloc, InvestorChatState>(
              builder: (context, state) {
                if (state is ChatLoading && _messageController.text.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesLoaded) {
                  final userId = context.read<AuthRepository>().currentUser?.id;
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == userId;
                      return _buildMessageBubble(message, isMe);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(InvestorMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundImage: message.senderAvatarUrl != null ? NetworkImage(message.senderAvatarUrl!) : null,
              child: message.senderAvatarUrl == null ? const Icon(Icons.person, size: 16) : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? AppColors.brandPurple : AppColors.surfaceGlass,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type an investment inquiry...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: AppColors.background.withValues(alpha: 0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton.small(
            onPressed: _sendMessage,
            backgroundColor: AppColors.brandPurple,
            child: const Icon(Icons.send, size: 18),
          ),
        ],
      ),
    );
  }
}
