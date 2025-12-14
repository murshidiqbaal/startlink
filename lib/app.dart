import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/auth/bloc/role_bloc.dart';
import 'package:startlink/features/auth/data/auth_remote_source.dart';
import 'package:startlink/features/auth/data/repository/auth_repository_impl.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/auth/presentation/login_screen.dart';
import 'package:startlink/features/home/presentation/collaborator_dashboard.dart';
import 'package:startlink/features/home/presentation/innovator_dashboard.dart';
import 'package:startlink/features/home/presentation/investor_dashboard.dart';
import 'package:startlink/features/home/presentation/mentor_dashboard.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRemoteDataSource>(
          create: (context) => AuthRemoteDataSourceImpl(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSource>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(AuthStarted()),
          ),
          BlocProvider(
            create: (context) =>
                RoleBloc(authRepository: context.read<AuthRepository>())
                  ..add(RoleStarted()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StartLink',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (authState is AuthAuthenticated) {
          // Listen to RoleBloc for the specific dashboard
          return BlocBuilder<RoleBloc, RoleState>(
            builder: (context, roleState) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: KeyedSubtree(
                  key: ValueKey(roleState.activeRole),
                  child: _buildDashboard(roleState.activeRole),
                ),
              );
            },
          );
        } else {
          return const LoginScreen();
        }
      },
    );
  }

  Widget _buildDashboard(String role) {
    switch (role) {
      case 'Innovator':
        return const InnovatorDashboard();
      case 'Collaborator':
        return const CollaboratorDashboard();
      case 'Investor':
        return const InvestorDashboard();
      case 'Mentor':
        return const MentorDashboard();
      default:
        return const InnovatorDashboard();
    }
  }
}
