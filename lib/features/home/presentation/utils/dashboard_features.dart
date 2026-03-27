import 'package:flutter/material.dart';

enum UserRole { admin, innovator, investor, mentor }

class DashboardFeature {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<UserRole> allowedRoles;
  final String? imageUrl;
  final String? routeName;
  final VoidCallback? onNavigate;

  const DashboardFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.allowedRoles,
    this.imageUrl,
    this.routeName,
    this.onNavigate,
  });
}

class DashboardConfig {
  static List<DashboardFeature> getAllFeatures(BuildContext context) {
    return [
      const DashboardFeature(
        id: 'home',
        title: 'Home',
        description: 'Your command center',
        icon: Icons.dashboard_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'idea',
        title: 'Ideas',
        description: 'Manage and post ideas',
        icon: Icons.lightbulb_rounded,
        allowedRoles: [UserRole.innovator, UserRole.mentor, UserRole.investor],
      ),
      const DashboardFeature(
        id: 'collaboration',
        title: 'Collaboration',
        description: 'Team up with others',
        icon: Icons.group_work_rounded,
        allowedRoles: [UserRole.innovator, UserRole.mentor],
      ),
      const DashboardFeature(
        id: 'ai_co_founder',
        title: 'AI Co-Founder',
        description: 'Your AI business partner',
        icon: Icons.psychology_rounded,
        allowedRoles: [UserRole.innovator],
        imageUrl: 'https://images.unsplash.com/photo-1675557009875-436f09789452?q=80&w=200&auto=format&fit=crop', // Sample for AI
      ),
      const DashboardFeature(
        id: 'ai_insights',
        title: 'AI Insights',
        description: 'Data-driven analysis',
        icon: Icons.analytics_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'compass',
        title: 'Compass',
        description: 'Navigate your startup journey',
        icon: Icons.explore_rounded,
        allowedRoles: [UserRole.innovator],
        imageUrl: 'https://images.unsplash.com/photo-1464852045489-bccb7d17fe39?q=80&w=200&auto=format&fit=crop', // Sample for Compass
      ),
      const DashboardFeature(
        id: 'investor',
        title: 'Investors',
        description: 'Connect with funding',
        icon: Icons.monetization_on_rounded,
        allowedRoles: [UserRole.innovator, UserRole.investor],
      ),
      const DashboardFeature(
        id: 'analytics',
        title: 'Analytics',
        description: 'Performance metrics',
        icon: Icons.bar_chart_rounded,
        allowedRoles: [UserRole.admin, UserRole.investor, UserRole.innovator],
      ),
      const DashboardFeature(
        id: 'pitch_health',
        title: 'Pitch Health',
        description: 'Analyze your pitch deck',
        icon: Icons.health_and_safety_rounded,
        allowedRoles: [UserRole.innovator],
      ),
      const DashboardFeature(
        id: 'idea_dna',
        title: 'Idea DNA',
        description: 'Core genetic makeup of your idea',
        icon: Icons.fingerprint_rounded,
        allowedRoles: [UserRole.innovator, UserRole.investor],
      ),
      const DashboardFeature(
        id: 'verification',
        title: 'Verification',
        description: 'Identity and trust badges',
        icon: Icons.verified_user_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'trust',
        title: 'Trust Score',
        description: 'Community reputation',
        icon: Icons.shield_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'achievements',
        title: 'Achievements',
        description: 'Milestones and badges',
        icon: Icons.emoji_events_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'aura',
        title: 'Aura',
        description: 'Personal energy and vibe',
        icon: Icons.bubble_chart_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'matching',
        title: 'Matching',
        description: 'Find your perfect co-founder',
        icon: Icons.handshake_rounded,
        allowedRoles: [UserRole.innovator],
        imageUrl: 'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?q=80&w=200&auto=format&fit=crop', // Sample for Matching
      ),
      const DashboardFeature(
        id: 'design_showcase',
        title: 'Showcase',
        description: 'Design gallery',
        icon: Icons.palette_rounded,
        allowedRoles: [UserRole.innovator, UserRole.investor],
      ),
      const DashboardFeature(
        id: 'profile',
        title: 'Profile',
        description: 'Manage your identity',
        icon: Icons.person_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'ai_feedback',
        title: 'AI Feedback',
        description: 'Smart feedback on your progress',
        icon: Icons.thumbs_up_down_rounded,
        allowedRoles: UserRole.values,
      ),
      const DashboardFeature(
        id: 'simulation',
        title: 'QA Simulation',
        description: 'Generate dummy data',
        icon: Icons.bug_report_rounded,
        allowedRoles: UserRole.values, // Available to all for testing now
      ),
      const DashboardFeature(
        id: 'admin',
        title: 'Admin',
        description: 'System administration',
        icon: Icons.admin_panel_settings_rounded,
        allowedRoles: [UserRole.admin],
      ),
    ];
  }
}
