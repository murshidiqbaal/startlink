import 'package:flutter/material.dart';

class ConfidenceTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>>
  history; // [{'confidence_score': 50, 'calculated_at': '...'}]

  const ConfidenceTrendChart({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'No confidence history yet.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Simple bar visualizer for MVP (Sparkline style)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confidence Trend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // or spaceArd
          children: history.map((entry) {
            final score = entry['confidence_score'] as int;
            final date = DateTime.parse(entry['calculated_at'] as String);
            final height = (score / 100) * 60; // Max height 60

            return Column(
              children: [
                Container(
                  width: 20,
                  height: height.toDouble(),
                  decoration: BoxDecoration(
                    color: _getColor(score),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Current: ${history.last['confidence_score']}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getColor(history.last['confidence_score'] as int),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
