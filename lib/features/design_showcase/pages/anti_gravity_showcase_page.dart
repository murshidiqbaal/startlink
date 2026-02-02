import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/anti_gravity_card.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_nav_bar.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/floating_widget.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/glass_card.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/hover_action_button.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/levitating_list_tile.dart';
import 'package:startlink/core/presentation/widgets/anti_gravity/neon_button.dart';
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
          "ORBITAL COMMAND",
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
                // 1. Hero Section Floating Card
                Center(
                  child: FloatingWidget(
                    intensity: 15.0,
                    duration: const Duration(seconds: 5),
                    child: GlassCard(
                      height: 200,
                      borderColor: Colors.cyanAccent.withValues(alpha: 0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "SYSTEM READY",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "All systems operational. Anti-gravity engine engaged.",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // 2. Section Header
                const Text(
                  "ACTIVE MODULES",
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Grid of Floating Cards with staggered animation (handled by manual delays in FloatingWidget if we wanted,
                // but here relying on random offsets in FloatingWidget default logic)
                Row(
                  children: [
                    Expanded(
                      child: FloatingWidget(
                        intensity: 8.0,
                        duration: const Duration(seconds: 6),
                        child: _buildModuleCard(
                          icon: Icons.shield_moon,
                          title: "Defense",
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FloatingWidget(
                        intensity: 12.0,
                        duration: const Duration(seconds: 7),
                        isReverse: true, // Floats opposite to neighbor
                        child: _buildModuleCard(
                          icon: Icons.bolt,
                          title: "Power",
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FloatingWidget(
                  intensity: 5.0,
                  duration: const Duration(seconds: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    borderColor: Colors.purpleAccent.withValues(alpha: 0.3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Communications",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Signal Strength: 100%",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.greenAccent,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 4. Action Buttons
                Center(
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      NeonButton(
                        text: "INITIATE LAUNCH",
                        onPressed: () {},
                        glowColor: Colors.cyanAccent,
                      ),
                      NeonButton(
                        text: "ABORT",
                        onPressed: () {},
                        glowColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // 5. Anti-Gravity & Tilt Cards
                const Text(
                  "INTERACTIVE GRAVITY MODULES",
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                AntiGravityCard(
                  height: 180,
                  onTap: () {},
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.touch_app,
                          color: Colors.cyanAccent,
                          size: 40,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Touch & Tilt",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Move cursor or touch to rotate 3D",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // 6. Levitating List
                const Text(
                  "ORBITAL DATA STREAM",
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return LevitatingListTile(
                      onTap: () {},
                      leading: Icon(
                        Icons.data_usage,
                        color: index == 0 ? Colors.greenAccent : Colors.white70,
                      ),
                      title: Text("Data Stream $index"),
                      subtitle: Text("Packet loss: 0.00${index + 1}%"),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.white30,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 100), // Space for FAB and NavBar
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: HoverActionButton(
        onPressed: () {},
        icon: Icons.add,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: 0,
        onItemSelected: (index) {},
        items: const [
          Icons.dashboard_rounded,
          Icons.rocket_launch_rounded,
          Icons.person_rounded,
        ],
      ),
    );
  }

  Widget _buildModuleCard({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return GlassCard(
      height: 150,
      borderColor: color.withValues(alpha: 0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
