import 'package:flutter/material.dart';
import 'package:startlink/features/collaboration/presentation/pages/collaboration_screen.dart';
import 'package:startlink/features/debug/presentation/simulation_dashboard.dart';
import 'package:startlink/features/home/presentation/utils/dashboard_features.dart';
import 'package:startlink/features/home/presentation/widgets/dashboard/dashboard_layout.dart';
import 'package:startlink/features/home/presentation/widgets/dashboard/feature_grid.dart';
import 'package:startlink/features/home/presentation/widgets/empty_state.dart';
import 'package:startlink/features/idea/presentation/idea_post_screen.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

class UnifiedDashboardScreen extends StatefulWidget {
  final UserRole userRole;

  const UnifiedDashboardScreen({super.key, required this.userRole});

  @override
  State<UnifiedDashboardScreen> createState() => _UnifiedDashboardScreenState();
}

class _UnifiedDashboardScreenState extends State<UnifiedDashboardScreen> {
  String _selectedFeatureId = 'home';

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      userRole: widget.userRole,
      selectedFeatureId: _selectedFeatureId,
      onFeatureSelected: (feature) {
        setState(() => _selectedFeatureId = feature.id);
        if (feature.onNavigate != null) {
          feature.onNavigate!();
        }
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_selectedFeatureId == 'home') {
      return FeatureGrid(
        userRole: widget.userRole,
        onFeatureSelected: (feature) {
          setState(() => _selectedFeatureId = feature.id);
        },
      );
    }

    // Map feature IDs to actual widgets here
    // For demonstration, we handle a few known ones or show placeholder
    switch (_selectedFeatureId) {
      case 'collaboration':
        return const CollaborationScreen();
      case 'profile':
        return const ProfileScreen();
      case 'simulation':
        return const SimulationDashboard();
      case 'idea': // Navigate to Idea Post for now, or Idea List if I had one
        // Usually 'idea' would show a list. Since I don't have a dedicated idea list page handy (InnovatorDashboard had it inline),
        // I'll leave it as home grid or create a placeholder that wraps IdeaPostScreen for demo?
        // Actually, InnovatorDashboard had "Your Ideas".
        // Let's just return EmptyState or IdeaPostScreen for demo.
        return const IdeaPostScreen();
      default:
        return Center(
          child: EmptyState(
            message: 'feature: $_selectedFeatureId\nComing Soon',
            actionLabel: 'Back to Home',
            onAction: () => setState(() => _selectedFeatureId = 'home'),
          ),
        );
    }
  }
}
