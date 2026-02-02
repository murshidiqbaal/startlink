import 'dart:math';

import 'package:flutter/material.dart';

class SpaceBackground extends StatelessWidget {
  final Widget? child;

  const SpaceBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Space Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF020012), // Deep Void
                Color(0xFF0F0B29), // Dark Nebula
                Color(0xFF1A1A40), // Distant Starfield
              ],
              stops: [0.0, 0.6, 1.0],
            ),
          ),
        ),

        // Static Starfield (Optimized with CustomPainter later if needed, simple mix here)
        const Positioned.fill(child: _StarField()),

        // Ambient Glows
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -150,
          right: -50,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _StarPainter());
  }
}

class _StarPainter extends CustomPainter {
  final Random _random = Random(42); // Fixed seed for consistent stars

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = Colors.white.withValues(alpha: 0.6);

    // Draw 100 random stars
    for (int i = 0; i < 100; i++) {
      final double x = _random.nextDouble() * size.width;
      final double y = _random.nextDouble() * size.height;
      final double radius = _random.nextDouble() * 1.5;
      final double opacity = _random.nextDouble();

      paint.color = Colors.white.withValues(alpha: opacity * 0.7);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
