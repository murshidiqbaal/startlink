import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/role_bloc.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Role')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildRoleButton(context, 'Innovator', Icons.lightbulb),
              _buildRoleButton(context, 'Collaborator', Icons.code),
              _buildRoleButton(context, 'Investor', Icons.attach_money),
              _buildRoleButton(context, 'Mentor', Icons.school),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String role, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(role),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          textStyle: const TextStyle(fontSize: 18),
        ),
        onPressed: () {
          context.read<RoleBloc>().add(RoleChanged(role));
        },
      ),
    );
  }
}
