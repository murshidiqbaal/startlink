import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/admin/presentation/pages/admin_ideas_page.dart';
import 'package:startlink/features/admin/presentation/pages/admin_overview_page.dart';
import 'package:startlink/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:startlink/features/admin/presentation/pages/admin_settings_page.dart';
import 'package:startlink/features/admin/presentation/pages/admin_users_page.dart';
import 'package:startlink/features/admin/presentation/pages/admin_verification_dashboard.dart';
import 'package:startlink/features/admin/presentation/widgets/admin_sidebar.dart';

class AdminDashboardLayout extends StatefulWidget {
  const AdminDashboardLayout({super.key});

  @override
  State<AdminDashboardLayout> createState() => _AdminDashboardLayoutState();
}

class _AdminDashboardLayoutState extends State<AdminDashboardLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminOverviewPage(),
    const AdminVerificationDashboard(),
    const AdminUsersPage(),
    const AdminIdeasPage(),
    const AdminReportsPage(),
    const AdminSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Determine if we should show the sidebar (Desktop) or a Drawer (Mobile)
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: !isDesktop
          ? AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: AppColors.background,
            )
          : null,
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: AppColors.surfaceGlass,
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _handleNavigation,
                isExtended: true,
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _handleNavigation,
              isExtended:
                  true, // Typically admin panels are always extended on desktop
            ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: IndexedStack(index: _selectedIndex, children: _pages),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    if (!mounted) return;
    setState(() => _selectedIndex = index);
    // If usage of Drawer (mobile), close it
    if (MediaQuery.of(context).size.width < 900 && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}
