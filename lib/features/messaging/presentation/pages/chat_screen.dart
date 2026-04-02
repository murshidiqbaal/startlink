// lib/features/messaging/presentation/pages/chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/features/messaging/data/repositories/message_repositoy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/message_model.dart';
// import '../../data/repositories/message_repository.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

/// Convenience method — call this from IdeaDetailScreen or anywhere else
/// to open a chat for a specific idea + innovator, without needing to
/// manually create a BlocProvider at the call site.
///
/// Usage:
///   ChatScreen.openForIdea(
///     context,
///     ideaId: idea.id,
///     ideaTitle: idea.title,
///     innovatorId: idea.ownerId,     // adjust field name to your IdeaModel
///     innovatorName: idea.ownerName, // adjust field name to your IdeaModel
///   );
extension ChatNavigation on BuildContext {
  Future<void> openChatForIdea({
    required String ideaId,
    required String ideaTitle,
    required String innovatorId,
    required String innovatorName,
  }) {
    return Navigator.push(
      this,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatBloc(repository: MessageRepository())
            ..add(
              OpenChat(
                ideaId: ideaId,
                otherUserId: innovatorId,
                ideaTitle: ideaTitle,
                otherUserName: innovatorName,
              ),
            ),
          child: const ChatScreen(),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final String _me = Supabase.instance.client.auth.currentUser!.id;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ChatBloc>().add(SendMessage(text));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatLoaded) _scrollToBottom();
      },
      builder: (context, state) {
        final loaded = state is ChatLoaded ? state : null;

        return Scaffold(
          appBar: AppBar(
            titleSpacing: 0,
            title: loaded == null
                ? const Text('Chat')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        loaded.otherUserName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        loaded.ideaTitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
          ),
          body: Column(
            children: [
              Expanded(child: _buildBody(state, theme, cs)),
              _InputBar(
                controller: _controller,
                enabled: loaded != null && !(loaded.isSending),
                isSending: loaded?.isSending ?? false,
                onSend: _send,
                cs: cs,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(ChatState state, ThemeData theme, ColorScheme cs) {
    if (state is ChatLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: cs.error),
              const SizedBox(height: 12),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (state is ChatLoaded) {
      if (state.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 64,
                color: cs.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No messages yet',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Say hello to ${state.otherUserName}!',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.outline),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        itemCount: state.messages.length,
        itemBuilder: (context, i) {
          final msg = state.messages[i];
          final isMe = msg.senderId == _me;

          final showDateDivider =
              i == 0 ||
              !_sameDay(state.messages[i - 1].createdAt, msg.createdAt);

          // Show avatar only on the first bubble in a sequence from this sender
          final isFirstInGroup =
              i == 0 || state.messages[i - 1].senderId != msg.senderId;

          return Column(
            children: [
              if (showDateDivider)
                _DateDivider(date: msg.createdAt, theme: theme, cs: cs),
              _Bubble(
                message: msg,
                isMe: isMe,
                showAvatar: !isMe && isFirstInGroup,
              ),
            ],
          );
        },
      );
    }

    return const SizedBox.square(dimension: 1);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Input bar ────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool isSending;
  final VoidCallback onSend;
  final ColorScheme cs;

  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.isSending,
    required this.onSend,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: enabled ? (_) => onSend() : null,
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: enabled ? onSend : null,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
                minimumSize: const Size(48, 48),
              ),
              child: isSending
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : const Icon(Icons.send_rounded, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date divider ─────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  final ThemeData theme;
  final ColorScheme cs;

  const _DateDivider({
    required this.date,
    required this.theme,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday =
        date.year == now.year &&
        date.month == now.month &&
        date.day == now.day - 1;

    final label = isToday
        ? 'Today'
        : isYesterday
        ? 'Yesterday'
        : DateFormat('MMMM d, y').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: cs.outlineVariant, thickness: 0.8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(color: cs.outline),
            ),
          ),
          Expanded(child: Divider(color: cs.outlineVariant, thickness: 0.8)),
        ],
      ),
    );
  }
}

// ── Message bubble ───────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showAvatar;

  const _Bubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Spacer for avatar column on my messages
          if (isMe) const SizedBox(width: 52),

          // Avatar on incoming messages
          if (!isMe) ...[
            if (showAvatar)
              CircleAvatar(
                radius: 16,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  '?', // The chat screen doesn't carry the avatar URL
                  // If you want real avatars, pass them through ChatState
                  style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer),
                ),
              )
            else
              const SizedBox(width: 32),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isMe ? 18 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isMe ? cs.onPrimary : cs.onSurface,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('HH:mm').format(message.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isMe
                              ? cs.onPrimary.withValues(alpha: 0.65)
                              : cs.outline,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 14,
                          color: cs.onPrimary.withValues(alpha: 0.65),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Spacer for avatar column on their messages
          if (!isMe) const SizedBox(width: 52),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
