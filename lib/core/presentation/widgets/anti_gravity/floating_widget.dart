import 'package:flutter/material.dart';
import 'dart:math' as math;

class FloatingWidget extends StatefulWidget {
  final Widget child;
  final double intensity;
  final Duration duration;
  final bool isReverse;

  const FloatingWidget({
    super.key,
    required this.child,
    this.intensity = 10.0,
    this.duration = const Duration(seconds: 4),
    this.isReverse = false,
  });

  @override
  State<FloatingWidget> createState() => _FloatingWidgetState();
}

class _FloatingWidgetState extends State<FloatingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // Sine wave motion for smooth, natural floating
    _animation = Tween<double>(begin: -widget.intensity, end: widget.intensity)
        .animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
        );

    // Desync animations slightly if needed by offsetting start
    if (widget.isReverse) {
      _controller.repeat(reverse: true);
    } else {
      Future.delayed(Duration(milliseconds: math.Random().nextInt(1000)), () {
        if (mounted) _controller.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
