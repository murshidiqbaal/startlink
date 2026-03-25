import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isExtended;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isExtended = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isExtended ? 250 : 80,
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // Logo or Title
          if (isExtended)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.brandPurple,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Admin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            )
          else
            const Icon(
              Icons.admin_panel_settings,
              color: AppColors.brandPurple,
              size: 28,
            ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _SidebarItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Overview',
                  isSelected: selectedIndex == 0,
                  onTap: () => onDestinationSelected(0),
                  isExtended: isExtended,
                ),
                _SidebarItem(
                  icon: Icons.verified_user_outlined,
                  activeIcon: Icons.verified_user,
                  label: 'Verification',
                  isSelected: selectedIndex == 1,
                  onTap: () => onDestinationSelected(1),
                  isExtended: isExtended,
                ),
                _SidebarItem(
                  icon: Icons.people_outline,
                  activeIcon: Icons.people,
                  label: 'Users',
                  isSelected: selectedIndex == 2,
                  onTap: () => onDestinationSelected(2),
                  isExtended: isExtended,
                ),
                _SidebarItem(
                  icon: Icons.lightbulb_outline,
                  activeIcon: Icons.lightbulb,
                  label: 'Ideas',
                  isSelected: selectedIndex == 3,
                  onTap: () => onDestinationSelected(3),
                  isExtended: isExtended,
                ),
                _SidebarItem(
                  icon: Icons.report_outlined,
                  activeIcon: Icons.report,
                  label: 'Reports',
                  isSelected: selectedIndex == 4,
                  onTap: () => onDestinationSelected(4),
                  isExtended: isExtended,
                ),
                const Divider(color: Colors.white10, height: 32),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: 'Settings',
                  isSelected: selectedIndex == 5,
                  onTap: () => onDestinationSelected(5),
                  isExtended: isExtended,
                ),
                _SidebarItem(
                  icon: Icons.logout_outlined,
                  activeIcon: Icons.logout,
                  label: 'Exit Admin',
                  isSelected: false,
                  onTap: () => Navigator.of(context).pop(),
                  isExtended: isExtended,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isExtended;
  final bool isDestructive;

  const _SidebarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isExtended,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? AppColors.rose
        : (isSelected ? AppColors.brandCyan : AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.brandCyan.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.brandCyan.withValues(alpha: 0.3))
                : null,
          ),
          child: Row(
            mainAxisAlignment: isExtended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 24),
              if (isExtended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? AppColors.textPrimary : color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
