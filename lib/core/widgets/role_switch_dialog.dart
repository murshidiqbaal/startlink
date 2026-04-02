import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/constants/user_role.dart';
import 'package:startlink/features/admin/presentation/pages/admin_verification_dashboard.dart';
import 'package:startlink/features/auth/bloc/role_bloc.dart';

void showRoleSwitchDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Switch Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...['Innovator', 'Investor', 'Collaborator', 'Mentor'].map(
              (role) => ListTile(
                title: Text(role),
                onTap: () {
                  context.read<RoleBloc>().add(
                    RoleChanged(UserRole.fromString(role)),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings,
                color: Colors.red,
              ),
              title: const Text('Admin Panel'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminVerificationDashboard(),
                  ),
                );
              },
            ),
          ],
        ),
      );
    },
  );
}
