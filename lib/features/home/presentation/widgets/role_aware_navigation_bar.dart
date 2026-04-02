import 'package:flutter/material.dart';
import 'package:startlink/core/widgets/role_switch_dialog.dart';

class RoleAwareNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  const RoleAwareNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: destinations.map((dest) {
        if (dest.label == 'Profile') {
          // Wrap Profile icon with LongPress gesture for Role Switching
          return NavigationDestination(
            icon: GestureDetector(
              onLongPress: () => showRoleSwitchDialog(context),
              child: dest.icon,
            ),
            selectedIcon: GestureDetector(
              onLongPress: () => showRoleSwitchDialog(context),
              child: dest.selectedIcon ?? dest.icon,
            ),
            label: dest.label,
          );
        }
        return dest;
      }).toList(),
    );
  }
}
