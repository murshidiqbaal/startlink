import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/investor_profile_screen.dart';
import 'package:startlink/features/profile/presentation/mentor_profile_screen.dart';
import 'package:startlink/features/verification/presentation/pages/verification_pending_screen.dart';
import 'package:startlink/features/verification/presentation/pages/verification_rejected_screen.dart';

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
    final userId = context.read<AuthRepository>().currentUser?.id;

    if (userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<VerificationBloc>().add(
              CheckVerificationStatus(userId, role),
            );
      });
    }

    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (context, state) {
        if (state is VerificationLoading || state is VerificationInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is VerificationApproved) {
          return child;
        }

        if (state is VerificationPending) {
          return VerificationPendingScreen(verification: state.verification);
        }

        if (state is VerificationRejected) {
          return VerificationRejectedScreen(verification: state.verification);
        }

        if (state is VerificationNotSubmitted) {
          if (role.toLowerCase() == 'investor') {
            return BlocProvider.value(
              value: context.read<InvestorProfileBloc>(),
              child: const InvestorProfileScreen(),
            );
          }

          if (role.toLowerCase() == 'mentor') {
            return BlocProvider.value(
              value: context.read<MentorProfileBloc>(),
              child: const MentorProfileScreen(),
            );
          }
        }

        if (state is VerificationError) {
          return Scaffold(body: Center(child: Text('Error: ${state.message}')));
        }

        return const Scaffold(body: Center(child: Text('Access Denied')));
      },
    );
  }
}
