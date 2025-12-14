import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/role_bloc.dart';

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
              onLongPress: () => _showRoleSwitchDialog(context),
              child: dest.icon,
            ),
            selectedIcon: GestureDetector(
              onLongPress: () => _showRoleSwitchDialog(context),
              child: dest.selectedIcon ?? dest.icon,
            ),
            label: dest.label,
          );
        }
        return dest;
      }).toList(),
    );
  }

  void _showRoleSwitchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Switch Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Innovator', 'Investor', 'Collaborator', 'Mentor']
                .map(
                  (role) => ListTile(
                    title: Text(role),
                    onTap: () {
                      context.read<RoleBloc>().add(RoleChanged(role));
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
