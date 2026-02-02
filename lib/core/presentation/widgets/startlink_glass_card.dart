import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class StartLinkGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool animate;
  final Gradient? borderGradient;

  const StartLinkGlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.animate = true,
    this.borderGradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = theme.extension<StartLinkColors>();
    final radius = borderRadius ?? BorderRadius.circular(16);

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: customColors?.surfaceGlass ?? const Color(0xFF15151A),
        borderRadius: radius,
        border: borderGradient == null
            ? Border.all(color: Colors.white.withValues(alpha: 0.05), width: 1)
            : null,
      ),
      child: child,
    );

    if (borderGradient != null) {
      content = Container(
        padding: const EdgeInsets.all(1), // Border width
        decoration: BoxDecoration(
          gradient: borderGradient,
          borderRadius: radius,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Container(
            color: customColors?.surfaceGlass ?? const Color(0xFF15151A),
            child: Padding(
              padding: padding, // Apply padding to inner child
              child: child,
            ),
          ),
        ),
      );
    } else {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: content,
        ),
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.05),
          ),
          child: content,
        ),
      );
    }

    // TODO: Add flutter_animate entry effect here if `animate` is true
    // when we integrate the package fully.
    return content;
  }
}
