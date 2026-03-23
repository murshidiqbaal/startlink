import 'package:flutter/material.dart';

import 'package:startlink/core/presentation/widgets/space_0/floating_widget.dart';
import 'package:startlink/core/presentation/widgets/space_0/glass_card.dart';
import 'package:startlink/core/presentation/widgets/space_0/tiltable_widget.dart';

class Space0Card extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const Space0Card({
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
