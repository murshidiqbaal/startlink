import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/home/presentation/widgets/stats_card.dart';

class AdminOverviewPage extends StatelessWidget {
  const AdminOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'System Overview',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          // Stats Row
          const Row(
            children: [
              Expanded(
                child: StatsCard(
                  label: 'Total Users',
                  value: '1,234',
                  icon: Icons.people,
                  iconColor: AppColors.brandPurple,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  label: 'Pending Verifications',
                  value: '42',
                  icon: Icons.verified_user,
                  iconColor: AppColors.amber,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  label: 'Investments (M)',
                  value: '\$2.4',
                  icon: Icons.monetization_on,
                  iconColor: AppColors.emerald,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: StatsCard(
                  label: 'Ideas Posted',
                  value: '840',
                  icon: Icons.lightbulb,
                  iconColor: AppColors.brandCyan,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          Text(
            'Recent Actions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Placeholder for recent logs
          Card(
            color: AppColors.surfaceGlass,
            child: const ListTile(
              leading: Icon(Icons.info_outline, color: AppColors.brandBlue),
              title: Text('User Verification Approved'),
              subtitle: Text('Admin1 approved Investor John Doe'),
              trailing: Text('2 mins ago'),
            ),
          ),
        ],
      ),
    );
  }
}
