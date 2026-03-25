// lib/features/messaging/presentation/pages/idea_inbox_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/features/messaging/data/repositories/message_repositoy.dart';

import '../../data/models/conversation_model.dart';
// import '../../data/repositories/message_repository.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/conversation_bloc.dart';
import '../bloc/conversation_event.dart';
import '../bloc/conversation_state.dart';
import 'chat_screen.dart';

class IdeaInboxScreen extends StatefulWidget {
  const IdeaInboxScreen({super.key});

  @override
  State<IdeaInboxScreen> createState() => _IdeaInboxScreenState();
}

class _IdeaInboxScreenState extends State<IdeaInboxScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ConversationBloc>().add(const LoadConversations());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        automaticallyImplyLeading: false,
        actions: [
          BlocBuilder<ConversationBloc, ConversationState>(
            builder: (context, state) => IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh',
              onPressed: () => context.read<ConversationBloc>().add(
                const RefreshConversations(),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ConversationBloc, ConversationState>(
        builder: (context, state) {
          // ── Loading ────────────────────────────────────────────────────────
          if (state is ConversationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ──────────────────────────────────────────────────────────
          if (state is ConversationError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 56,
                      color: cs.error.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load messages',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.tonal(
                      onPressed: () => context.read<ConversationBloc>().add(
                        const LoadConversations(),
                      ),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Loaded ─────────────────────────────────────────────────────────
          if (state is ConversationLoaded) {
            if (state.conversations.isEmpty) {
              return _EmptyInbox(cs: cs, theme: theme);
            }

            return RefreshIndicator(
              onRefresh: () async => context.read<ConversationBloc>().add(
                const RefreshConversations(),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.conversations.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 80, endIndent: 16),
                itemBuilder: (context, i) {
                  final conv = state.conversations[i];
                  return _ConversationTile(
                    conversation: conv,
                    onTap: () => _openChat(context, conv),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _openChat(BuildContext context, ConversationModel conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => ChatBloc(repository: MessageRepository())
            ..add(
              OpenChat(
                ideaId: conv.ideaId,
                otherUserId: conv.otherUserId,
                ideaTitle: conv.ideaTitle,
                otherUserName: conv.otherUserName,
              ),
            ),
          child: const ChatScreen(),
        ),
      ),
    ).then((_) {
      // Silently refresh conversation list after returning from chat
      if (context.mounted) {
        context.read<ConversationBloc>().add(const RefreshConversations());
      }
    });
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyInbox extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  const _EmptyInbox({required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.forum_outlined, size: 56, color: cs.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No conversations yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Browse ideas and reach out to innovators\nto start collaborating.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conversation tile ─────────────────────────────────────────────────────────

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final VoidCallback onTap;
  const _ConversationTile({required this.conversation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasUnread = conversation.hasUnread;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _Avatar(
              name: conversation.otherUserName,
              imageUrl: conversation.otherUserAvatar,
              cs: cs,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: name + timestamp
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.otherUserName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(conversation.lastMessageAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: hasUnread ? cs.primary : cs.outline,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Row 2: idea chip
                  _IdeaChip(
                    title: conversation.ideaTitle,
                    cs: cs,
                    theme: theme,
                  ),
                  const SizedBox(height: 6),

                  // Row 3: last message + unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: hasUnread
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                            fontWeight: hasUnread
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread) ...[
                        const SizedBox(width: 8),
                        _UnreadBadge(count: conversation.unreadCount, cs: cs),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays == 0) return DateFormat('HH:mm').format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('dd/MM').format(dt);
  }
}

class _Avatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final ColorScheme cs;
  const _Avatar({required this.name, required this.imageUrl, required this.cs});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: cs.primaryContainer,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : null,
    );
  }
}

class _IdeaChip extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  final ThemeData theme;
  const _IdeaChip({required this.title, required this.cs, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 12,
            color: cs.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSecondaryContainer,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  final ColorScheme cs;
  const _UnreadBadge({required this.count, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: TextStyle(
          color: cs.onPrimary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
