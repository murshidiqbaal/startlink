import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/ai_co_founder/domain/entities/chat_message.dart';
import 'package:startlink/features/ai_co_founder/domain/repositories/co_founder_repository.dart';
import 'package:startlink/features/ai_co_founder/presentation/bloc/co_founder_bloc.dart';

class CoFounderChatScreen extends StatelessWidget {
  final String? contextId;

  const CoFounderChatScreen({super.key, this.contextId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CoFounderBloc(repository: context.read<CoFounderRepository>()),
      child: _CoFounderDashboard(contextId: contextId),
    );
  }
}

class _CoFounderDashboard extends StatefulWidget {
  final String? contextId;
  const _CoFounderDashboard({this.contextId});

  @override
  State<_CoFounderDashboard> createState() => _CoFounderDashboardState();
}

class _CoFounderDashboardState extends State<_CoFounderDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Co-Founder'),
        backgroundColor: AppColors.surfaceGlass,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.brandCyan,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.brandCyan,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Chat', icon: Icon(Icons.chat_bubble_outline)),
            Tab(text: 'Insights', icon: Icon(Icons.lightbulb_outline)),
            Tab(text: 'Action Plan', icon: Icon(Icons.checklist)),
            Tab(text: 'Risks', icon: Icon(Icons.warning_amber_rounded)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ChatTab(contextId: widget.contextId),
          _InsightsTab(),
          _ActionsTab(),
          _RisksTab(),
        ],
      ),
    );
  }
}

class _ChatTab extends StatefulWidget {
  final String? contextId;
  const _ChatTab({this.contextId});

  @override
  State<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<_ChatTab> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    context.read<CoFounderBloc>().add(
      SendMessage(text, contextId: widget.contextId),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocConsumer<CoFounderBloc, CoFounderState>(
            listener: (context, state) {
              if (state.messages.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
            },
            builder: (context, state) {
              if (state.messages.isEmpty &&
                  state.status == CoFounderStatus.initial) {
                return _buildEmptyState();
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    state.messages.length +
                    (state.status == CoFounderStatus.loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.messages.length) {
                    return const _TypingIndicator(); // Show typing if loading
                  }
                  final msg = state.messages[index];
                  return _MessageBubble(message: msg);
                },
              );
            },
          ),
        ),
        _buildInputArea(context),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology,
            size: 64,
            color: AppColors.brandCyan.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Pitch me your idea.\nI'll be brutally honest.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      color: AppColors.surfaceGlass,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Discuss your strategy...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.brandCyan,
              onPressed: _sendMessage,
              child: const Icon(Icons.send, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoFounderBloc, CoFounderState>(
      builder: (context, state) {
        if (state.insights.isEmpty) {
          return const Center(
            child: Text(
              'Start chatting to generate insights.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.insights.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StartLinkGlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      color: AppColors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.insights[index],
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ActionsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoFounderBloc, CoFounderState>(
      builder: (context, state) {
        if (state.actionItems.isEmpty) {
          return const Center(
            child: Text(
              'No action items yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.actionItems.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StartLinkGlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.brandCyan,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.actionItems[index],
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RisksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoFounderBloc, CoFounderState>(
      builder: (context, state) {
        if (state.risks.isEmpty) {
          return const Center(
            child: Text(
              'No risks identified yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.risks.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StartLinkGlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.rose,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.risks[index],
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.brandCyan.withOpacity(0.2)
              : AppColors.surfaceGlass,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          border: Border.all(
            color: isUser
                ? AppColors.brandCyan.withOpacity(0.3)
                : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const Text(
                'AI Co-Founder',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.brandPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              message.text,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Text(
          'Thinking...',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
