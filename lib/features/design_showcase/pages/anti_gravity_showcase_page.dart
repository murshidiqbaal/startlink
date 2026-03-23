import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/anti_gravity_card.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_nav_bar.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_widget.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/glass_card.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/space_background.dart';

class AntiGravityShowcasePage extends StatelessWidget {
  const AntiGravityShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ZERO-G INTERFACE",
          style: TextStyle(
            fontFamily: 'Courier',
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            color: Colors.white70,
          ),
        ),
        centerTitle: true,
      ),
      body: SpaceBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 100, bottom: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("INNOVATOR // VERTICAL ASCENSION"),
                const SizedBox(height: 16),
                const FloatingWidget(
                  intensity: 15.0,
                  duration: Duration(seconds: 4),
                  direction: Axis.vertical,
                  child: GlassCard(
                    height: 180,
                    borderColor: Colors.cyanAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 48,
                            color: Colors.cyanAccent,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "The Idea",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Floating upwards like a bubble",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                _buildSectionHeader("COLLABORATOR // HORIZONTAL DRIFT"),
                const SizedBox(height: 16),
                const FloatingWidget(
                  intensity: 10.0,
                  duration: Duration(seconds: 5),
                  direction: Axis.horizontal,
                  child: GlassCard(
                    height: 120,
                    borderColor: Colors.indigoAccent,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.compare_arrows,
                          size: 32,
                          color: Colors.indigoAccent,
                        ),
                        SizedBox(width: 16),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Connection Flow",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Drifting side-to-side",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                _buildSectionHeader("MENTOR // STABLE GUIDANCE"),
                const SizedBox(height: 16),
                const FloatingWidget(
                  intensity: 5.0,
                  duration: Duration(seconds: 8), // Slow
                  child: GlassCard(
                    height: 140,
                    borderColor: Colors.amber,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Icon(Icons.school, size: 40, color: Colors.amber),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              "Ancient wisdom floats slowly and steadily.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                _buildSectionHeader("INVESTOR // GROUNDED CONFIDENCE"),
                const SizedBox(height: 16),
                const FloatingWidget(
                  intensity: 2.0, // Very subtle
                  duration: Duration(seconds: 6),
                  child: GlassCard(
                    height: 120,
                    borderColor: Colors.tealAccent,
                    child: Center(
                      child: ListTile(
                        leading: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.tealAccent,
                          size: 32,
                        ),
                        title: Text(
                          "Solid Assets",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "Minimal movement. Maximum stability.",
                          style: TextStyle(color: Colors.white38),
                        ),
                        trailing: Text(
                          "\$1.2M",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                _buildSectionHeader("INTERACTIVE // ANTI-GRAVITY TOUCH"),
                const SizedBox(height: 16),
                AntiGravityCard(
                  height: 200,
                  onTap: () {},
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 48,
                          color: Colors.purpleAccent,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Touch Me",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "I react to your presence",
                          style: TextStyle(color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: 1,
        onItemSelected: (i) {},
        items: const [Icons.home, Icons.explore, Icons.person],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white54,
          letterSpacing: 2.0,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
