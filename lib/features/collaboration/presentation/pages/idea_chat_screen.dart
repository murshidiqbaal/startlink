import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_widget.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';

class IdeaChatScreen extends StatefulWidget {
  final String ideaId;
  final String ideaTitle;

  const IdeaChatScreen({
    super.key,
    required this.ideaId,
    required this.ideaTitle,
  });

  @override
  State<IdeaChatScreen> createState() => _IdeaChatScreenState();
}

class _IdeaChatScreenState extends State<IdeaChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock Messages
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      id: '1',
      senderName: 'Alex Innovator',
      role: 'Innovator',
      message:
          'Welcome everyone! I’ve just updated the pitch deck in the files tab. Please review it by EOD.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      avatarUrl: null,
    ),
    _ChatMessage(
      id: '2',
      senderName: 'Sarah Collab',
      role: 'Collaborator',
      message: 'Checking it now. The market analysis looks solid.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      avatarUrl: null,
    ),
    _ChatMessage(
      id: '3',
      senderName: 'Mike Tech',
      role: 'Collaborator',
      message:
          'I noticed a typo on slide 4, but otherwise the tech stack is accurately represented.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      avatarUrl: null,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          id: DateTime.now().toString(),
          senderName: 'Me', // Current User
          role: 'Collaborator', // Assume current user role
          message: _controller.text.trim(),
          timestamp: DateTime.now(),
          avatarUrl: null,
          isMe: true,
        ),
      );
      _controller.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Text(
              'Public Discussion',
              style: TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              children: [
                Icon(Icons.people, size: 14, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  "4",
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Message Composer
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final bool isInnovator = msg.role == 'Innovator';
    final bool isMe = msg.isMe;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Align to bottom of avatar
        children: [
          if (!isMe) ...[
            _buildAvatar(msg.senderName, isInnovator),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: FloatingWidget(
              intensity: 2.0, // Very subtle float
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
                      : isInnovator
                      ? Colors.cyan.withValues(
                          alpha: 0.15,
                        ) // Highlight Innovator
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: isMe
                        ? const Radius.circular(20)
                        : const Radius.circular(4),
                    bottomRight: isMe
                        ? const Radius.circular(4)
                        : const Radius.circular(20),
                  ),
                  border: Border.all(
                    color: isMe
                        ? AppColors.brandPurple.withValues(alpha: 0.4)
                        : isInnovator
                        ? Colors.cyanAccent.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.1),
                    width: isInnovator ? 1.5 : 1.0,
                  ),
                  boxShadow: isInnovator
                      ? [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.senderName,
                              style: TextStyle(
                                color: isInnovator
                                    ? Colors.cyanAccent
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            if (isInnovator) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.star,
                                size: 10,
                                color: Colors.cyanAccent,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "Owner",
                                style: TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    Text(
                      msg.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        _formatTime(msg.timestamp),
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
        color: isHighlight
            ? Colors.cyanAccent.withValues(alpha: 0.2)
            : AppColors.brandPurple.withValues(alpha: 0.2),
        border: Border.all(
          color: isHighlight
              ? Colors.cyanAccent.withValues(alpha: 0.5)
              : Colors.white24,
        ),
      ),
      child: Center(
        child: Text(
          name[0],
          style: TextStyle(
            color: isHighlight ? Colors.cyanAccent : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
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
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 24,
        ), // account for safe area
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Share your thoughts publicly...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                    BoxShadow(
                      color: Colors.purpleAccent,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}

class _ChatMessage {
  final String id;
  final String senderName;
  final String? avatarUrl;
  final String role;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  _ChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.role,
    required this.timestamp,
    this.avatarUrl,
    this.isMe = false,
  });
}
