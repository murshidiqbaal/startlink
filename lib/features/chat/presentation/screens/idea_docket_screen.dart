import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/domain/entities/team_member.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_room_bloc.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_room_event.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_room_state.dart';
import 'package:startlink/features/chat/presentation/widgets/premium_chat_bubble.dart';
import 'package:startlink/features/chat/presentation/widgets/premium_chat_input.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IdeaDocketScreen extends StatelessWidget {
  final String teamId;
  final String ideaTitle;

  const IdeaDocketScreen({
    super.key,
    required this.teamId,
    required this.ideaTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ChatRoomBloc(context.read<ChatRepository>())
            ..add(LoadTeamMessages(teamId)),
      child: _IdeaDocketView(ideaTitle: ideaTitle, teamId: teamId),
    );
  }
}

class _IdeaDocketView extends StatefulWidget {
  final String ideaTitle;
  final String teamId;

  const _IdeaDocketView({required this.ideaTitle, required this.teamId});

  @override
  State<_IdeaDocketView> createState() => _IdeaDocketViewState();
}

class _IdeaDocketViewState extends State<_IdeaDocketView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    
    context.read<ChatRoomBloc>().add(
      SendTeamMessage(widget.teamId, text),
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
        title: BlocBuilder<ChatRoomBloc, ChatRoomState>(
          builder: (context, state) {
            List<TeamMember> members = [];
            if (state is ChatRoomLoaded) {
              members = state.teamMembers;
            }
            return Row(
              children: [
                Expanded(
                  child: Column(
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
                      Text(
                        '${members.length} Team Members',
                        style: TextStyle(
                          fontSize: 10, 
                          color: AppColors.brandCyan.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildAvatarStack(members),
              ],
            );
          },
        ),
        backgroundColor: AppColors.background.withValues(alpha: 0.5),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPurple.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: BlocConsumer<ChatRoomBloc, ChatRoomState>(
                  listener: (context, state) {
                    if (state is ChatRoomLoaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    if (state is ChatRoomLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ChatRoomError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    } else if (state is ChatRoomLoaded) {
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
                          
                          // Only show avatar for the first message in a sequence
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
                hintText: 'Message team...',
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
            Icons.forum_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Be the first to say hello!',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<TeamMember> members) {
    if (members.isEmpty) return const SizedBox();

    return SizedBox(
      height: 32,
      width: 80,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          members.take(4).length,
          (index) {
            final member = members[index];
            return Positioned(
              right: index * 18.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.brandPurple,
                  backgroundImage: member.avatarUrl != null 
                      ? NetworkImage(member.avatarUrl!) 
                      : null,
                  child: member.avatarUrl == null 
                      ? Text(
                          member.fullName?[0].toUpperCase() ?? '?',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
