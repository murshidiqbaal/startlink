import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/role_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<RoleBloc, RoleState>(
            listener: (context, state) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Role updated to ${state.activeRole}')),
              );
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              final user = state.user;
              // STARTLINK: Role is now managed via RoleBloc/Auth combination.
              // We display the one from AuthBloc (backend truth) but use RoleBloc to change it.
              final role = user.userMetadata?['role'] ?? 'Role not set';
              final email = user.email ?? 'No Email';

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300',
                      ), // Placeholder
                    ),
                    const SizedBox(height: 16),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          role,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.blue,
                          ),
                          onPressed: () => _showRoleDialog(context, role),
                          tooltip: 'Edit Role',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Edit Profile'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Skills & Interests'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        Chip(label: Text('Flutter')),
                        Chip(label: Text('AI/ML')),
                        Chip(label: Text('Product Management')),
                        Chip(label: Text('Startup')),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Recent Activity'),
                    const SizedBox(height: 8),
                    _buildActivityItem('Posted a new idea: "EcoDrone"'),
                    _buildActivityItem('Joined "SmartCity" project'),
                    _buildActivityItem('Updated profile skills'),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showRoleDialog(context, role),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.deepPurple),
                        ),
                        child: const Text('Change Role'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    //logout button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, String currentRole) {
    showDialog(
      context: context,
      builder: (context) {
        String selectedRole = currentRole;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Role'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRoleTile(
                      'Innovator',
                      selectedRole,
                      (val) => setState(() => selectedRole = val),
                    ),
                    _buildRoleTile(
                      'Collaborator',
                      selectedRole,
                      (val) => setState(() => selectedRole = val),
                    ),
                    _buildRoleTile(
                      'Mentor',
                      selectedRole,
                      (val) => setState(() => selectedRole = val),
                    ),
                    _buildRoleTile(
                      'Investor',
                      selectedRole,
                      (val) => setState(() => selectedRole = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedRole != currentRole) {
                      context.read<RoleBloc>().add(RoleChanged(selectedRole));
                      // Also trigger AuthBloc update to ensure backend data is refreshed in UI
                      context.read<AuthBloc>().add(
                        AuthUpdateRoleRequested(role: selectedRole),
                      );
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRoleTile(
    String role,
    String groupValue,
    Function(String) onChanged,
  ) {
    return RadioListTile<String>(
      title: Text(role),
      value: role,
      groupValue: groupValue,
      onChanged: (value) => onChanged(value!),
      activeColor: Colors.deepPurple,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history, color: Colors.deepPurple),
        title: Text(text),
      ),
    );
  }
}
