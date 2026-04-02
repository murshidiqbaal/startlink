import 'package:flutter/material.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/investor/presentation/pages/investor_pitch_requests_screen.dart';
import 'package:startlink/features/investor/presentation/pages/investor_chat_list_screen.dart';
import 'package:startlink/features/investor/presentation/pages/investor_dashboard_screen.dart';
import 'package:startlink/features/mentor/presentation/pages/mentor_reels_screen.dart';
import 'package:startlink/features/profile/presentation/investor_profile_screen.dart';
import 'package:startlink/features/verification/presentation/widgets/role_verification_guard.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InvestorDashboardScreen(),
    const InvestorPitchRequestsScreen(),
    const InvestorChatListScreen(),
    const MentorReelsScreen(),
    const InvestorProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RoleVerificationGuard(
        role: 'investor',
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: RoleAwareNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Hub',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
