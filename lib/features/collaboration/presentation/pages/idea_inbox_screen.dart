import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/glass_card.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_widget.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/presentation/pages/idea_chat_screen.dart';

class IdeaInboxScreen extends StatelessWidget {
  const IdeaInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock Data for Idea Threads
    final threads = [
      _IdeaThread(
        id: '1',
        title: 'Eco-Friendly Packaging',
        lastMessage: 'I uploaded the new design drafts for review.',
        lastActive: '2m ago',
        collaboratorsCount: 4,
        isUnread: true,
      ),
      _IdeaThread(
        id: '2',
        title: 'AI Health Assistant',
        lastMessage: 'Innovator: Let’s schedule a sync for tomorrow.',
        lastActive: '1h ago',
        collaboratorsCount: 2,
        isUnread: false,
      ),
      _IdeaThread(
        id: '3',
        title: 'Urban Farming Drone',
        lastMessage: 'Collaborator: The battery stats look promising.',
        lastActive: '1d ago',
        collaboratorsCount: 6,
        isUnread: false,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Idea Dockets',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: threads.length,
        itemBuilder: (context, index) {
          final thread = threads[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: FloatingWidget(
              intensity: 3.0,
              duration: Duration(seconds: 4 + index), // Desync animations
              child: GlassCard(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => IdeaChatScreen(
                        ideaId: thread.id,
                        ideaTitle: thread.title,
                      ),
                    ),
                  );
                },
                height: 100,
                borderColor: thread.isUnread
                    ? Colors.cyanAccent.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    // Idea Icon / Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          thread.title.isNotEmpty ? thread.title[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Thread Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                thread.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                thread.lastActive,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            thread.lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: thread.isUnread
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.6),
                              fontWeight: thread.isUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Stats
                          Row(
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 14,
                                color: Colors.cyanAccent.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${thread.collaboratorsCount} Collaborators',
                                style: TextStyle(
                                  color: Colors.cyanAccent.withValues(
                                    alpha: 0.7,
                                  ),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (thread.isUnread) ...[
                      const SizedBox(width: 12),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.cyanAccent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.cyanAccent, blurRadius: 8),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IdeaThread {
  final String id;
  final String title;
  final String lastMessage;
  final String lastActive;
  final int collaboratorsCount;
  final bool isUnread;

  _IdeaThread({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastActive,
    required this.collaboratorsCount,
    required this.isUnread,
  });
}
