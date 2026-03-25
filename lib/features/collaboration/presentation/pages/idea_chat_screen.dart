import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_widget.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_room_bloc.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_room_event.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_room_state.dart';
import 'package:startlink/features/chat/domain/entities/message.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';

class IdeaChatScreen extends StatelessWidget {
  final String ideaId;
  final String groupId;
  final String ideaTitle;

  const IdeaChatScreen({
    super.key,
    required this.ideaId,
    required this.groupId,
    required this.ideaTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatRoomBloc(
        context.read<ChatRepository>(),
        Supabase.instance.client,
      )..add(LoadMessages(ideaId, groupId)),
      child: _IdeaChatView(ideaTitle: ideaTitle, groupId: groupId),
    );
  }
}

class _IdeaChatView extends StatefulWidget {
  final String ideaTitle;
  final String groupId;

  const _IdeaChatView({required this.ideaTitle, required this.groupId});

  @override
  State<_IdeaChatView> createState() => _IdeaChatViewState();
}

class _IdeaChatViewState extends State<_IdeaChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    context.read<ChatRoomBloc>().add(
          SendMessage(widget.groupId, _controller.text.trim()),
        );
    _controller.clear();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ideaTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            const Text(
              'Public Discussion',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatRoomBloc, ChatRoomState>(
              listener: (context, state) {
                if (state is ChatRoomLoaded) {
                   Future.delayed(const Duration(milliseconds: 100), () {
                    if (_scrollController.hasClients) {
                        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });
                }
              },
              builder: (context, state) {
                if (state is ChatRoomLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatRoomError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                } else if (state is ChatRoomLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final msg = state.messages[index];
                      final isMe = msg.senderId == Supabase.instance.client.auth.currentUser?.id;
                      return _buildMessageBubble(msg, isMe);
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _buildAvatar(msg.senderName ?? '?', false),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: FloatingWidget(
              intensity: 2.0,
              duration: const Duration(seconds: 4),
              isReverse: isMe,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.brandPurple.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isMe
                        ? AppColors.brandPurple.withValues(alpha: 0.4)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          msg.senderName ?? 'Anonymous',
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    Text(
                      msg.content,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatTime(msg.createdAt),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[const SizedBox(width: 8), _buildAvatar('Me', false)],
        ],
      ),
    );
  }

  Widget _buildAvatar(String name, bool isHighlight) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isHighlight ? Colors.cyanAccent.withValues(alpha: 0.2) : AppColors.brandPurple.withValues(alpha: 0.2),
        border: Border.all(color: isHighlight ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.white24),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : '?',
          style: TextStyle(color: isHighlight ? Colors.cyanAccent : Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return GlassCard(
      borderRadius: 0,
      blur: 20,
      borderColor: Colors.white.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts publicly...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.startLinkGradient,
                  boxShadow: [
                    BoxShadow(color: Colors.purpleAccent, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) => "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
}

