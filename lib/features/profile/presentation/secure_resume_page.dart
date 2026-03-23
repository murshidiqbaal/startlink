import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:startlink/core/presentation/widgets/space_0/floating_widget.dart';
import 'package:startlink/core/presentation/widgets/space_0/glass_card.dart';
import 'package:startlink/core/presentation/widgets/space_0/space_0_card.dart';

class SecureResumePage extends StatefulWidget {
  const SecureResumePage({super.key});

  @override
  State<SecureResumePage> createState() => _SecureResumePageState();
}

class _SecureResumePageState extends State<SecureResumePage> {
  // Mock authentication states for different sections
  bool _isContactInfoUnlocked = false; // Private by default
  bool _isDocumentsUnlocked = false; // Private by default

  // To verify biometric animation state
  bool _isAuthenticating = false;

  void _authenticate(VoidCallback onSuccess) {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    // Mock biometric scanning delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        onSuccess();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep professional blue/slate
      body: Stack(
        children: [
          // Background Elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blue.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Custom Secure AppBar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 80,
                floating: true,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "SECURE ID",
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white54),
                    onPressed: () {},
                    tooltip: 'Access Logs',
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 12,
                          color: Colors.greenAccent,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "VERIFIED",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Identity Header
                      _buildIdentityHeader(),
                      const SizedBox(height: 30),

                      // 2. Personal Info (Locked)
                      _buildSecureSection(
                        title: "Sensitive Information",
                        icon: Icons.fingerprint,
                        isUnlocked: _isContactInfoUnlocked,
                        onUnlock: () => _authenticate(
                          () => setState(() => _isContactInfoUnlocked = true),
                        ),
                        floatingIntensity: 8.0,
                        child: _buildContactInfo(),
                      ),
                      const SizedBox(height: 24),

                      // 3. Education & Skills (Always Visible)
                      _buildSectionTitle("Education & Expertise"),
                      const SizedBox(height: 12),
                      FloatingWidget(
                        intensity: 5.0,
                        duration: const Duration(seconds: 6),
                        child: GlassCard(
                          child: Column(
                            children: [
                              _buildTimelineItem(
                                year: "2024",
                                title: "Senior Product Architect",
                                subtitle: "StartLink Innovations",
                                isLast: false,
                              ),
                              _buildTimelineItem(
                                year: "2021",
                                title: "Master of Computer Science",
                                subtitle: "Stanford University",
                                isLast: true,
                              ),
                              const Divider(color: Colors.white10),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildSkillChip("Flutter"),
                                  _buildSkillChip("System Design"),
                                  _buildSkillChip("AI Integration"),
                                  _buildSkillChip("Blockchain"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // 4. Secure Vault
                      _buildSecureSection(
                        title: "Document Vault",
                        icon: Icons.lock_person_sharp,
                        isUnlocked: _isDocumentsUnlocked,
                        onUnlock: () => _authenticate(
                          () => setState(() => _isDocumentsUnlocked = true),
                        ),
                        floatingIntensity:
                            0.0, // Heavy/Fixed when locked looks good too, but logic handles it
                        child: _buildDocumentVault(),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Authentication Overlay
          if (_isAuthenticating)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.fingerprint,
                          size: 64,
                          color: Colors.cyanAccent,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Verifying Biometrics...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.cyanAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIdentityHeader() {
    return Space0Card(
      height: 220,
      onTap: () {}, // Interactive tilt
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(
                "https://i.pravatar.cc/300?img=11",
              ), // Placeholder
              backgroundColor: Colors.white10,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "ALEXANDER NOVO",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Full Stack Innovator • AI Specialist",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat("Exp", "7 Yrs"), // Experience
              _buildVerticalDivider(),
              _buildStat("Projects", "102"),
              _buildVerticalDivider(),
              _buildStat("Trust", "98%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 15),
      color: Colors.white24,
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSecureSection({
    required String title,
    required IconData icon,
    required bool isUnlocked,
    required VoidCallback onUnlock,
    required Widget child,
    double floatingIntensity = 5.0,
  }) {
    // If locked, zero float intensity (heavy). If unlocked, float.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: isUnlocked
              ? FloatingWidget(
                  key: ValueKey('unlocked_$title'),
                  intensity: floatingIntensity,
                  child: GlassCard(
                    borderColor: Colors.greenAccent.withValues(alpha: 0.3),
                    child: child,
                  ),
                )
              : GestureDetector(
                  key: ValueKey('locked_$title'),
                  onTap: onUnlock,
                  child: Container(
                    // Locked State: "Heavier", no float, blurred
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Blurred content preview (fake)
                          Positioned.fill(
                            child: ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                              ),
                              child: Container(
                                color: Colors.white.withValues(alpha: 0.05),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 200,
                                      color: Colors.white10,
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height: 20,
                                      width: 150,
                                      color: Colors.white10,
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      height: 20,
                                      width: double.infinity,
                                      color: Colors.white10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Lock Overlay
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white54,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Tap to Auth",
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.email, "alex.novo@startlink.com"),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.white10),
        ),
        _buildInfoRow(Icons.phone, "+1 (555) 019-2834"),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.white10),
        ),
        _buildInfoRow(Icons.location_on, "San Francisco, CA (Remote)"),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.cyanAccent, size: 20),
        const SizedBox(width: 16),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String year,
    required String title,
    required String subtitle,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.cyanAccent,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(child: Container(width: 2, color: Colors.white10)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year,
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white70)),
    );
  }

  Widget _buildDocumentVault() {
    return Column(
      children: [
        _buildDocRow("Resume_2026.pdf", "2.4 MB", true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.white10),
        ),
        _buildDocRow("NDA_Signed.pdf", "1.1 MB", true),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.white10),
        ),
        _buildDocRow("Identity_Passport.jpg", "4.5 MB", true),
      ],
    );
  }

  Widget _buildDocRow(String name, String size, bool isEncrypted) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.picture_as_pdf,
            color: Colors.redAccent,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                size,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (isEncrypted)
          const Tooltip(
            message: 'Encrypted',
            child: Icon(
              Icons.lock_rounded,
              color: Colors.greenAccent,
              size: 16,
            ),
          ),
        const SizedBox(width: 12),
        const Icon(Icons.download_rounded, color: Colors.white54),
      ],
    );
  }
}
