import 'package:flutter/material.dart';
import 'package:startlink/features/home/presentation/utils/dashboard_features.dart';
import 'package:startlink/features/home/presentation/widgets/dashboard/feature_card.dart';

class FeatureGrid extends StatelessWidget {
  final UserRole userRole;
  final Function(DashboardFeature) onFeatureSelected;

  const FeatureGrid({
    super.key,
    required this.userRole,
    required this.onFeatureSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allFeatures = DashboardConfig.getAllFeatures(context);
    // Filter: Hide Admin for non-admins, but show others as locked if no access
    final visibleFeatures = allFeatures.where((f) {
      if (f.id == 'admin' && userRole != UserRole.admin) return false;
      return true;
    }).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 1.0,
      ),
      itemCount: visibleFeatures.length,
      itemBuilder: (context, index) {
        final feature = visibleFeatures[index];
        final hasAccess = feature.allowedRoles.contains(userRole);

        return FeatureCard(
          title: feature.title,
          description: feature.description,
          icon: feature.icon,
          isLocked: !hasAccess,
          lockReason: !hasAccess
              ? 'Available for ${feature.allowedRoles.map((e) => e.name).join(", ")}'
              : null,
          onTap: () => onFeatureSelected(feature),
        );
      },
    );
  }
}
