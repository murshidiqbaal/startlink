import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import '../bloc/chat_room_bloc.dart';
import '../bloc/chat_room_event.dart';
import '../bloc/chat_room_state.dart';

class ChatScreen extends StatelessWidget {
  final String ideaId;
  final String groupId;
  final String ideaTitle;

  const ChatScreen({
    super.key,
    required this.ideaId,
    required this.groupId,
    required this.ideaTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ChatRoomBloc(
        ctx.read<ChatRepository>(),
        Supabase.instance.client,
      )..add(LoadMessages(ideaId, groupId)),
      child: _ChatRoomView(ideaTitle: ideaTitle, groupId: groupId),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final String ideaTitle;
  final String groupId;
  const _ChatRoomView({required this.ideaTitle, required this.groupId});

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isNotEmpty) {
        context.read<ChatRoomBloc>().add(SendMessage(widget.groupId, text));
      _msgCtrl.clear();
      // Animate smoothly to the very bottom (which is offset 0 on a reversed list)
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(0.0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ideaTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            BlocBuilder<ChatRoomBloc, ChatRoomState>(
              builder: (context, state) {
                if (state is ChatRoomLoaded) {
                  return Text(
                    "${state.teamMembers.length} members",
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  );
                }
                return const Text(
                  "Team Chat",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatRoomBloc, ChatRoomState>(
              listener: (context, state) {
                // Removed manual timer scroll to bottom; reverse: true handles it gracefully.
              },
              builder: (context, state) {
                if (state is ChatRoomLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
                }
                if (state is ChatRoomError) {
                  return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: AppColors.rose)));
                }
                if (state is ChatRoomLoaded) {
                  return ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    reverse: true, // Crucial for instant bottom-anchored real-time UX
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      // Because the list is reversed, index 0 is at the bottom (newest)
                      final actualIndex = state.messages.length - 1 - index;
                      final msg = state.messages[actualIndex];
                      final isMe = msg.senderId == userId;
                      return _MessageBubble(
                        message: msg.content,
                        isMe: isMe,
                        senderName: msg.senderName,
                        senderAvatar: msg.senderAvatar,
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(top: Border.all(color: Colors.white.withValues(alpha: 0.05)).top),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.brandPurple),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String? senderName;
  final String? senderAvatar;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.senderName,
    this.senderAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe && senderName != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                senderName!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.brandPurple.withValues(alpha: 0.2),
                  backgroundImage: senderAvatar != null ? NetworkImage(senderAvatar!) : null,
                  child: senderAvatar == null
                      ? Text(
                          senderName?.isNotEmpty == true ? senderName![0].toUpperCase() : "?",
                          style: const TextStyle(fontSize: 10, color: AppColors.brandPurple),
                        )
                      : null,
                ),
              if (!isMe) const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.brandPurple : AppColors.surfaceGlass,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
