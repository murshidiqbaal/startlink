import 'package:flutter/material.dart';

class HoverActionButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color glowColor;

  const HoverActionButton({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
    this.glowColor = Colors.cyanAccent,
  });

  @override
  State<HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<HoverActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isHovered ? 70 : 60,
            height: _isHovered ? 70 : 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(
                color: widget.glowColor.withValues(alpha: 0.8),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(
                    alpha: _isHovered ? 0.6 : 0.3,
                  ),
                  blurRadius: _isHovered ? 25 : 15,
                  spreadRadius: _isHovered ? 5 : 2,
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
