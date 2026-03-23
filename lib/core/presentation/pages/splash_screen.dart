import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:startlink/app.dart'; // For AuthGate/DeepLinkHandler
import 'package:startlink/features/auth/presentation/auth_deep_link_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _floatController;

  // Entrance Animations
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _textSlide;

  // Floating/Breathing Animations
  late Animation<double> _floatY;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Controller (One-shot sequences)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 2. Floating Controller (Looping)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // --- Definitions ---

    // Logo Fades In quickly
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Text Slides Up and Fades In
    _textSlide =
        Tween<Offset>(
          begin: const Offset(0, 0.2), // Starts slightly below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );

    // Tagline Fades In last
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // --- Floating/Breathing ---

    // Vertical Float (Sine wave-like via reverse)
    _floatY = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Glow Pulse (Breathing)
    _glowPulse = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );

    // Start Animation
    _entranceController.forward();

    // Navigate away after animation + delay
    Timer(const Duration(seconds: 4), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              const AuthDeepLinkHandler(child: AuthGate()),
          transitionDuration: const Duration(milliseconds: 800),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Deep gradient background
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep Slate
      body: Stack(
        children: [
          // Background Gradient & Particles (Mocked with blurs)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A), // Deep Dark Blue
                    Color(0xFF1E1B4B), // Indigo
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
          ),

          // Ambient Glow Top Left
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Ambient Glow Bottom Right
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.1),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Floating Logo with Pulse
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _entranceController,
                    _floatController,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatY.value), // Vertical float
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow behind logo
                            Transform.scale(
                              scale:
                                  1.0 + (_glowPulse.value * 0.2), // Pulse size
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent.withOpacity(
                                        0.3 * _glowPulse.value,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(
                                        0.2 * _glowPulse.value,
                                      ),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Logo Icon
                            // Constructing a custom logo shape:
                            // A "StartLink" hub node or geometric S
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF22D3EE),
                                    Color(0xFF818CF8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.hub_outlined,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // App Name
                AnimatedBuilder(
                  animation: _entranceController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Column(
                          children: [
                            Text(
                              'StartLink',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  BoxShadow(
                                    color: Colors.cyanAccent.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tagline
                            FadeTransition(
                              opacity: _taglineFade,
                              child: Text(
                                'Innovate. Connect. Scale.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey[200],
                                  letterSpacing: 3.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
