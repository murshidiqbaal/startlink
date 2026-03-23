import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:startlink/features/verification/presentation/pages/investor_setup_screen.dart';
import 'package:startlink/features/verification/presentation/pages/mentor_setup_screen.dart';
import 'package:startlink/features/verification/presentation/pages/verification_pending_screen.dart';

class RoleVerificationGuard extends StatelessWidget {
  final String role;
  final Widget child;

  const RoleVerificationGuard({
    super.key,
    required this.role,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (context, state) {
        if (state is VerificationLoading || state is VerificationInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is VerificationLoaded) {
          // 1. Is already verified for this role?
          if (state.isRoleVerified(role)) {
            return child;
          }

          // 2. Is there a pending/rejected request?
          final request = state.getRequestForRole(role);
          if (request != null) {
            return VerificationPendingScreen(verification: request);
          }

          // 3. No request yet, show setup screen
          if (role.toLowerCase() == 'investor') {
            return const InvestorSetupScreen();
          } else if (role.toLowerCase() == 'mentor') {
            return const MentorSetupScreen();
          }
        }

        if (state is VerificationError) {
          return Scaffold(
            body: Center(child: Text('Error: ${state.message}')),
          );
        }

        return const Scaffold(
          body: Center(child: Text('Access Denied')),
        );
      },
    );
  }
}
