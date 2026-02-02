import 'package:flutter/material.dart';

class AIInfoTooltip extends StatelessWidget {
  const AIInfoTooltip({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 18, color: Colors.grey),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.psychology, color: Colors.purple),
                SizedBox(width: 8),
                Text('About AI Insights'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoint(
                  Icons.check_circle_outline,
                  'Based on idea content & public signals.',
                  Colors.green,
                ),
                const SizedBox(height: 8),
                _buildPoint(
                  Icons.lock_outline,
                  'No private financial data is used.',
                  Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildPoint(
                  Icons.update,
                  'Updates when you edit idea or receive feedback.',
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI insights are supportive signals to help you decide, not financial advice.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPoint(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
