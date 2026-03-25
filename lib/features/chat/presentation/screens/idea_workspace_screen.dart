import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/presentation/screens/chat_screen.dart';
import 'package:startlink/features/collaboration/presentation/screens/idea_team_screen.dart';

class IdeaWorkspaceScreen extends StatefulWidget {
  final String ideaId;
  final String roomId;
  final String ideaTitle;

  const IdeaWorkspaceScreen({
    super.key,
    required this.ideaId,
    required this.roomId,
    required this.ideaTitle,
  });

  @override
  State<IdeaWorkspaceScreen> createState() => _IdeaWorkspaceScreenState();
}

class _IdeaWorkspaceScreenState extends State<IdeaWorkspaceScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      ChatScreen(
        roomId: widget.roomId,
        ideaTitle: widget.ideaTitle,
      ),
      IdeaTeamScreen(
        ideaId: widget.ideaId,
        ideaTitle: widget.ideaTitle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.surfaceGlass,
            indicatorColor: AppColors.brandPurple.withValues(alpha: 0.2),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.bold);
              }
              return const TextStyle(color: AppColors.textSecondary, fontSize: 12);
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: AppColors.brandPurple);
              }
              return const IconThemeData(color: AppColors.textSecondary);
            }),
          ),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: 'Team Chat',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: 'Idea Team',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
