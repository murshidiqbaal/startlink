import 'package:flutter/material.dart';

import '../../../../core/presentation/widgets/anti_gravity/floating_widget.dart';
import '../../../../core/presentation/widgets/anti_gravity/glass_card.dart';
import '../../../../core/presentation/widgets/anti_gravity/tiltable_widget.dart';

class AntiGravityCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const AntiGravityCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingWidget(
      intensity: 8.0,
      duration: const Duration(seconds: 5),
      child: TiltableWidget(
        child: GlassCard(
          width: width ?? double.infinity,
          height: height,
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }
}
