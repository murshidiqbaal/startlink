import 'package:flutter/material.dart';

class TiltableWidget extends StatefulWidget {
  final Widget child;
  final double maxTiltAngle;
  final double sensitivity;

  const TiltableWidget({
    super.key,
    required this.child,
    this.maxTiltAngle = 0.1, // Approx 5-6 degrees
    this.sensitivity = 1.0,
  });

  @override
  State<TiltableWidget> createState() => _TiltableWidgetState();
}

class _TiltableWidgetState extends State<TiltableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Current values
  double _rotationX = 0.0;
  double _rotationY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Size size = box.size;
    final Offset position = event.localPosition;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Calculate normalized distance from center (-1.0 to 1.0)
    final double dx = (position.dx - center.dx) / (size.width / 2);
    final double dy = (position.dy - center.dy) / (size.height / 2);

    setState(() {
      // Invert Y axis for natural tilt feel (or not, depends on preference)
      // If we push Top, it should rotate X negative (tilt away).
      _rotationX = -dy * widget.maxTiltAngle * widget.sensitivity;
      _rotationY = dx * widget.maxTiltAngle * widget.sensitivity;
    });
  }

  void _onExit(PointerEvent event) {
    // Animate back to zero?
    // For simplicity with basic SetState, we just snap back or we can use an implicit animation approach.
    // Let's rely on AnimatedContainer or Transform animation if possible, but Matrix4 is complex.
    // We'll use a TweenAnimationBuilder for smooth reset? No, that's heavy.
    // Let's just set to 0. A Tween<Matrix4> is better but `Transform` handles rapid updates better.
    // To make it smooth on exit, we just set state to 0.
    // To make movements smooth, we wrap the Transform in an implicit animation widget like AnimatedContainer?
    // AnimatedContainer doesn't support Matrix4 transform alignment simply for 3D.

    // We will just snap back for now for responsiveness, or use a simplistic lerp in logic.
    setState(() {
      _rotationX = 0.0;
      _rotationY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using TweenAnimationBuilder to smooth out the tilt transitions
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: TweenAnimationBuilder<Offset>(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        tween: Tween<Offset>(
          begin: Offset.zero,
          end: Offset(_rotationX, _rotationY),
        ),
        builder: (context, values, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateX(values.dx)
              ..rotateY(values.dy),
            child: widget.child,
          );
        },
      ),
    );
  }
}
