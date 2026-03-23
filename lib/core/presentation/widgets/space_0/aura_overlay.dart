import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/space_0/glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';

class AuraOverlay {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AuraAnimation(
        message: message,
        isError: isError,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlayState.insert(overlayEntry);
  }
}

class _AuraAnimation extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _AuraAnimation({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_AuraAnimation> createState() => _AuraAnimationState();
}

class _AuraAnimationState extends State<_AuraAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    await _controller.forward();
    await Future.delayed(const Duration(seconds: 2));
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isError ? AppColors.rose : AppColors.brandCyan;

    return Positioned.fill(
      child: Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Modal Barrier (optional, prevents touches while showing status)
            // GestureDetector(onTap: () {}, child: Container(color: Colors.transparent)),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: GlassCard(
                    borderRadius: 24,
                    borderColor: color.withValues(alpha: 0.5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isError
                                ? Icons.error_outline
                                : Icons.check_circle_outline,
                            size: 48,
                            color: color,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
