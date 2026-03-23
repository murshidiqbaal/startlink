import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 64, color: AppColors.brandPurple),
            const SizedBox(height: 16),
            const Text('System Analytics Report'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report downloading...')),
                );
              },
              icon: const Icon(Icons.download),
              label: const Text('Download CSV'),
            ),
          ],
        ),
      ),
    );
  }
}
