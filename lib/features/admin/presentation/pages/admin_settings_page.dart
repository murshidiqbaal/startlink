import 'package:flutter/material.dart';
import 'package:startlink/core/theme/app_theme.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _maintenanceMode = false;
  bool _registrationOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('System Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text(
              'Maintenance Mode',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'Only admins can access the site',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            value: _maintenanceMode,
            onChanged: (val) {
              setState(() => _maintenanceMode = val);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Settings Saved")));
            },
            tileColor: AppColors.surfaceGlass,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text(
              'Registration Open',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'Allow new users to sign up',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            value: _registrationOpen,
            onChanged: (val) {
              setState(() => _registrationOpen = val);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Settings Saved")));
            },
            tileColor: AppColors.surfaceGlass,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}
