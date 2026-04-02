import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/constants/user_role.dart';
import 'package:startlink/features/profile/presentation/edit_collaborator_profile.dart';
import 'package:startlink/features/profile/presentation/edit_innovator_profile.dart';
import 'package:startlink/features/profile/presentation/edit_investor_profile.dart';
import 'package:startlink/features/profile/presentation/edit_mentor_profile.dart';
import 'package:startlink/features/role_management/presentation/bloc/profile_gate_bloc.dart';
import 'package:startlink/features/role_management/presentation/bloc/profile_gate_state.dart';

class RoleGateWrapper extends StatelessWidget {
  final Widget child;

  const RoleGateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileGateBloc, ProfileGateState>(
      listener: (context, state) {
        if (state is ProfileGateBlocked) {
          _showBlockingModal(context, state);
        }
      },
      child: child,
    );
  }

  void _showBlockingModal(BuildContext context, ProfileGateBlocked state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Welcome! Let\'s set up your profile.'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your ${state.role.toStringValue} profile is ${state.completionPercentage}% complete.',
              ),
              const SizedBox(height: 10),
              const Text(
                'Missing:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...state.missingFields.map((field) => Text('• $field')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _navigateToEditScreen(context, state);
              },
              child: Text('Complete ${state.role.toStringValue} Profile'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(BuildContext context, ProfileGateBlocked state) {
    // Navigate to respective edit screen
    Widget screen;
    switch (state.role) {
      case UserRole.innovator:
        screen = EditInnovatorProfileScreen(profileId: state.baseProfile.id);
        break;
      case UserRole.mentor:
        screen = EditMentorProfileScreen(profileId: state.baseProfile.id);
        break;
      case UserRole.investor:
        screen = EditInvestorProfileScreen(profileId: state.baseProfile.id);
        break;
      case UserRole.collaborator:
        screen = EditCollaboratorProfileScreen(profileId: state.baseProfile.id);
        break;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
}
