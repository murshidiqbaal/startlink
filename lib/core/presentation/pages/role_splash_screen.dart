import 'dart:async';

import 'package:flutter/material.dart';

class RoleSplashScreen extends StatefulWidget {
  final String role;
  final VoidCallback onCompleted;

  const RoleSplashScreen({
    super.key,
    required this.role,
    required this.onCompleted,
  });

  @override
  State<RoleSplashScreen> createState() => _RoleSplashScreenState();
}

class _RoleSplashScreenState extends State<RoleSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    _playAnimation();
  }

  void _playAnimation() {
    // Total Duration ~ 1.5s
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 1. Icon Fades In & Scales Up (0 - 500ms)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // 2. Text Fades In (300ms - 800ms)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeOut),
      ),
    );

    // Start
    _controller.forward().then((_) {
      // Hold for a moment then complete
      Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          widget.onCompleted();
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  (Color, IconData, String) _getRoleAttributes(String role) {
    switch (role.toLowerCase()) {
      case 'investor':
        return (const Color(0xFF2DD4BF), Icons.trending_up, "Investor"); // Teal
      case 'mentor':
        return (
          const Color(0xFFF59E0B),
          Icons.school_outlined,
          "Mentor",
        ); // Amber
      case 'innovator':
      case 'founder':
      case 'user':
        return (
          const Color(0xFF22D3EE),
          Icons.rocket_launch_outlined,
          "Innovator",
        ); // Cyan
      case 'collaborator':
        return (
          const Color(0xFF818CF8),
          Icons.group_work_outlined,
          "Collaborator",
        ); // Indigo
      case 'admin':
        return (
          const Color(0xFFE11D48),
          Icons.security_outlined,
          "Admin",
        ); // Rose
      default:
        return (Colors.white, Icons.person_outline, role);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (color, icon, label) = _getRoleAttributes(widget.role);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.1),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(icon, color: color, size: 48),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: Column(
                children: [
                  Text(
                    'Welcome',
                    style: TextStyle(
                      color: Colors.blueGrey[300],
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A wrapper that handles showing the splash screen when a role is active.
class RoleSplashWrapper extends StatefulWidget {
  final String role;
  final Widget child;

  const RoleSplashWrapper({super.key, required this.role, required this.child});

  @override
  State<RoleSplashWrapper> createState() => _RoleSplashWrapperState();
}

class _RoleSplashWrapperState extends State<RoleSplashWrapper> {
  bool _showSplash = true; // Show splash by default on mount
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant RoleSplashWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.role != oldWidget.role && widget.role.isNotEmpty) {
      // Role changed, show splash
      setState(() {
        _showSplash = true;
      });
    }
  }

  void _onSplashCompleted() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If splash is active, show it
    if (_showSplash && widget.role.isNotEmpty) {
      return RoleSplashScreen(
        role: widget.role,
        onCompleted: _onSplashCompleted,
      );
    }

    // Otherwise show the actual dashboard
    return widget.child;
  }
}
