import 'package:flutter/material.dart';

class VerificationStatusChip extends StatelessWidget {
  final bool isVerified;
  final String label;

  const VerificationStatusChip({
    super.key,
    required this.isVerified,
    this.label = 'Verified',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified
            ? Colors.green.withOpacity(0.1)
            : Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isVerified ? Colors.green : Colors.amber),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 14,
            color: isVerified ? Colors.green : Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            isVerified
                ? label
                : 'Pending', // Or 'Not Verified' based on context if needed
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isVerified ? Colors.green : Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
