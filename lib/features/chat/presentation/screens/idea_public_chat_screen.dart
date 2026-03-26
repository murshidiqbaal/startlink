import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import 'package:startlink/features/chat/presentation/bloc/public_chat_bloc.dart';
import 'package:startlink/features/chat/presentation/bloc/public_chat_event.dart';
import 'package:startlink/features/chat/presentation/bloc/public_chat_state.dart';
import 'package:startlink/features/chat/presentation/widgets/premium_chat_bubble.dart';
import 'package:startlink/features/chat/presentation/widgets/premium_chat_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdeaPublicChatScreen extends StatelessWidget {
  final String groupId;
  final String ideaId;
  final String ideaTitle;

  const IdeaPublicChatScreen({
    super.key,
    required this.groupId,
    required this.ideaId,
    required this.ideaTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PublicChatBloc(context.read<ChatRepository>())
            ..add(LoadPublicMessages(groupId)),
      child: _IdeaPublicChatView(ideaTitle: ideaTitle, groupId: groupId),
    );
  }
}

class _IdeaPublicChatView extends StatefulWidget {
  final String ideaTitle;
  final String groupId;

  const _IdeaPublicChatView({required this.ideaTitle, required this.groupId});

  @override
  State<_IdeaPublicChatView> createState() => _IdeaPublicChatViewState();
}

class _IdeaPublicChatViewState extends State<_IdeaPublicChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    context.read<PublicChatBloc>().add(
      SendPublicMessage(widget.groupId, text),
    );
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ColorFilter.mode(Colors.black.withValues(alpha: 0.2), BlendMode.darken),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ideaTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              'Public Discussion',
              style: TextStyle(
                fontSize: 10, 
                color: Colors.cyanAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background.withValues(alpha: 0.5),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: BlocConsumer<PublicChatBloc, PublicChatState>(
                  listener: (context, state) {
                    if (state is PublicChatLoaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    if (state is PublicChatLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is PublicChatError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is PublicChatLoaded) {
                      if (state.messages.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final msg = state.messages[index];
                          final isMe = msg.senderId == _currentUserId;
                          
                          bool showAvatar = index == 0 || 
                                          state.messages[index - 1].senderId != msg.senderId;

                          return PremiumChatBubble(
                            message: msg,
                            isMe: isMe,
                            showAvatar: showAvatar,
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              PremiumChatInput(
                controller: _controller,
                onSend: _sendMessage,
                hintText: 'Share your thoughts...',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start the conversation',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Text(
            'Anyone can see and join this discussion.',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
