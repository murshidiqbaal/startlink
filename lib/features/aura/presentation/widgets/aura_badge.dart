import 'package:flutter/material.dart';

class AuraBadge extends StatelessWidget {
  final int points;
  final bool showLabel;
  final bool animate;

  const AuraBadge({
    super.key,
    required this.points,
    this.showLabel = true,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    if (points < 0) return const SizedBox.shrink();

    return Tooltip(
      message: 'Aura reflects your contribution to the StartLink ecosystem.',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade900, Colors.purple.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text(
              '$points${showLabel ? ' Aura' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
