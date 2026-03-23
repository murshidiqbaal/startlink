import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/auth/presentation/login_screen.dart';

class AdminGuard extends StatelessWidget {
  final Widget child;

  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          // Check for admin role in user metadata
          final role = state.user.userMetadata?['role'];
          // Or check specific admin claim if you have set it up in Supabase
          // For now, we assume 'role' == 'admin' or 'super_admin' provides access.
          // Alternatively, an admin might also have a standard role but an 'is_admin' flag.

          bool isAdmin = role == 'admin' || role == 'super_admin';

          // Debug/Development Override:
          // If you are using specific emails for admins, you can check here too.
          // if (state.user.email == 'admin@startlink.com') isAdmin = true;

          if (isAdmin) {
            return child;
          } else {
            // Not authorized
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text('Access Denied: Admins Only'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back'),
                    ),
                  ],
                ),
              ),
            );
          }
        } else if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const LoginScreen();
      },
    );
  }
}
