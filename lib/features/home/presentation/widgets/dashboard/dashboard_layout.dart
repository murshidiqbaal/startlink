import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/home/presentation/utils/dashboard_features.dart';
import 'package:startlink/features/home/presentation/widgets/dashboard/dashboard_sidebar.dart';

class DashboardLayout extends StatelessWidget {
  final UserRole userRole;
  final String selectedFeatureId;
  final Function(DashboardFeature) onFeatureSelected;
  final Widget child;

  const DashboardLayout({
    super.key,
    required this.userRole,
    required this.selectedFeatureId,
    required this.onFeatureSelected,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: !isDesktop
          ? AppBar(
              title: const Text('StartLink'),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            )
          : null,
      drawer: !isDesktop
          ? Drawer(
              child: DashboardSidebar(
                userRole: userRole,
                selectedFeatureId: selectedFeatureId,
                onFeatureSelected: onFeatureSelected,
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            DashboardSidebar(
              userRole: userRole,
              selectedFeatureId: selectedFeatureId,
              onFeatureSelected: onFeatureSelected,
            ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // Optional Breadcrumb or Header for Desktop
                  if (isDesktop)
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      child: Text(
                        DashboardConfig.getAllFeatures(context)
                            .firstWhere(
                              (f) => f.id == selectedFeatureId,
                              orElse: () =>
                                  DashboardConfig.getAllFeatures(context).first,
                            )
                            .title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
