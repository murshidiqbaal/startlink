import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/home/presentation/utils/dashboard_features.dart';

class DashboardSidebar extends StatelessWidget {
  final UserRole userRole;
  final String selectedFeatureId;
  final Function(DashboardFeature) onFeatureSelected;

  const DashboardSidebar({
    super.key,
    required this.userRole,
    required this.selectedFeatureId,
    required this.onFeatureSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allFeatures = DashboardConfig.getAllFeatures(context);
    final visibleFeatures = allFeatures.where((f) {
      if (f.id == 'admin' && userRole != UserRole.admin) return false;
      return true;
    }).toList();

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              itemCount: visibleFeatures.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final feature = visibleFeatures[index];
                final isSelected = feature.id == selectedFeatureId;
                final hasAccess = feature.allowedRoles.contains(userRole);

                return _SidebarItem(
                  feature: feature,
                  isSelected: isSelected,
                  hasAccess: hasAccess,
                  onTap: () => onFeatureSelected(feature),
                );
              },
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.startLinkGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.rocket_launch,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'StartLink',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://i. Pravatar.cc/150',
            ), // Placeholder
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'User Profile',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                userRole.name.toUpperCase(),
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final DashboardFeature feature;
  final bool isSelected;
  final bool hasAccess;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.feature,
    required this.isSelected,
    required this.hasAccess,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.isSelected
        ? AppColors.brandCyan
        : widget.hasAccess
        ? AppColors.textSecondary
        : AppColors.textSecondary.withValues(alpha: 0.3);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.hasAccess ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppColors.brandPurple.withValues(alpha: 0.15)
                : _isHovered && widget.hasAccess
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.brandPurple.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.isSelected ? widget.feature.icon : widget.feature.icon,
                color: widget.isSelected ? AppColors.brandCyan : color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.feature.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.isSelected ? Colors.white : color,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (!widget.hasAccess)
                Icon(Icons.lock_outline, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
