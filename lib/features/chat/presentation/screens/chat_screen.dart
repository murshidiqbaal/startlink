import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import '../bloc/chat_room_bloc.dart';
import '../bloc/chat_room_event.dart';
import '../bloc/chat_room_state.dart';

class ChatScreen extends StatelessWidget {
  final String roomId;
  final String ideaTitle;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.ideaTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ChatRoomBloc(
        ctx.read<ChatRepository>(),
        Supabase.instance.client,
      )..add(LoadMessages(roomId)),
      child: _ChatRoomView(ideaTitle: ideaTitle, roomId: roomId),
    );
  }
}

class _ChatRoomView extends StatefulWidget {
  final String ideaTitle;
  final String roomId;
  const _ChatRoomView({required this.ideaTitle, required this.roomId});

  @override
  State<_ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<_ChatRoomView> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = _msgCtrl.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatRoomBloc>().add(SendMessageEvent(widget.roomId, text));
      _msgCtrl.clear();
      // Scroll to bottom immediately for better UX
      Timer(const Duration(milliseconds: 100), _scrollToBottom);
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
            const Text(
              "Team Chat",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatRoomBloc, ChatRoomState>(
              listener: (context, state) {
                if (state is ChatRoomLoaded) {
                  Timer(const Duration(milliseconds: 100), _scrollToBottom);
                }
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
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == userId;
                      return _MessageBubble(message: msg.message, isMe: isMe);
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

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
    );
  }
}
