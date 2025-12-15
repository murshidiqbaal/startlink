import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/auth/bloc/role_bloc.dart';
import 'package:startlink/features/auth/data/auth_remote_source.dart';
import 'package:startlink/features/auth/data/repository/auth_repository_impl.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/auth/presentation/auth_deep_link_handler.dart';
import 'package:startlink/features/auth/presentation/login_screen.dart';
import 'package:startlink/features/auth/presentation/role_selection_screen.dart';
import 'package:startlink/features/collaboration/data/repositories/collaboration_repository_impl.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/home/presentation/collaborator_dashboard.dart';
import 'package:startlink/features/home/presentation/innovator_dashboard.dart';
import 'package:startlink/features/home/presentation/investor_dashboard.dart';
import 'package:startlink/features/home/presentation/mentor_dashboard.dart';
import 'package:startlink/features/idea/data/repositories/idea_repository_impl.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';

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
        RepositoryProvider<IdeaRepository>(
          create: (context) => IdeaRepositoryImpl(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(),
        ),
        RepositoryProvider<CollaborationRepository>(
          create: (context) => CollaborationRepositoryImpl(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(AuthStarted()),
          ),
          BlocProvider<RoleBloc>(
            create: (context) =>
                RoleBloc(authRepository: context.read<AuthRepository>())
                  ..add(RoleStarted()),
          ),
          BlocProvider<IdeaBloc>(
            create: (context) =>
                IdeaBloc(ideaRepository: context.read<IdeaRepository>())
                  ..add(FetchIdeas()),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              profileRepository: context.read<ProfileRepository>(),
            )..add(FetchProfile()),
          ),
          BlocProvider<CollaborationBloc>(
            create: (context) => CollaborationBloc(
              repository: context.read<CollaborationRepository>(),
            ),
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
      home: const AuthDeepLinkHandler(child: AuthGate()),
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
              if (roleState.activeRole.isNotEmpty) {
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
              } else {
                return const RoleSelectionScreen();
              }
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
        return const InnovatorDashboard(); // Default or RoleScreen
    }
  }
}
