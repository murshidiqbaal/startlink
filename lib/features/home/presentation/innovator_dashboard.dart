import 'package:flutter/material.dart';
import 'package:startlink/features/home/presentation/profile_screen.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';

class InnovatorDashboard extends StatefulWidget {
  const InnovatorDashboard({super.key});

  @override
  State<InnovatorDashboard> createState() => _InnovatorDashboardState();
}

class _InnovatorDashboardState extends State<InnovatorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [const InnovatorHome(), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: RoleAwareNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
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

class InnovatorHome extends StatelessWidget {
  const InnovatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Innovator Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Analytics'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(context, 'Views', '1.2k', 0.7),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildAnalyticsCard(context, 'Likes', '340', 0.4),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'My Ideas'),
            _buildIdeaCard(
              'EcoDrone',
              'Sustainable drone delivery system.',
              'Looking for Co-founder',
            ),
            _buildIdeaCard(
              'HealthTrack',
              'AI-powered health monitoring.',
              'Funding Needed',
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Collaborators Needed'),
            _buildInfoCard(
              context,
              'Project "EcoDrone" needs a Backend Dev.',
              Icons.group_add,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Funding Requests'),
            _buildInfoCard(
              context,
              '2 Pending Investor Reviews',
              Icons.monetization_on,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Idea'),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        // color: Colors.black87, // Removed for dark mode compatibility
      ),
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context,
    String title,
    String value,
    double progress,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdeaCard(String title, String description, String status) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description),
            const SizedBox(height: 4),
            Chip(
              label: Text(status, style: const TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String text, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(top: 10),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
