import 'package:flutter/material.dart';

class AuraLeaderboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>>
  leaders; // [{'full_name': '...', 'aura_points': 450, 'role': 'Innovator'}]

  const AuraLeaderboardScreen({super.key, required this.leaders});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Contributors ✨')),
      body: leaders.isEmpty
          ? const Center(child: Text('Be the first to earn Aura!'))
          : ListView.separated(
              itemCount: leaders.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = leaders[index];
                final isTop3 = index < 3;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isTop3
                        ? Colors.amber[100 * (4 - index)]
                        : Colors.grey[200],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTop3 ? Colors.amber[900] : Colors.black,
                      ),
                    ),
                  ),
                  title: Text(user['full_name'] ?? 'User'),
                  subtitle: Text(
                    user['role'] ?? 'Member',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${user['aura_points']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
