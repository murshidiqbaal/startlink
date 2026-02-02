import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/services/supabase_client.dart'; // Import Supabase Service
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/achievements/data/repositories/achievement_repository_impl.dart';
import 'package:startlink/features/achievements/domain/repositories/achievement_repository.dart';
import 'package:startlink/features/achievements/presentation/bloc/achievement_bloc.dart';
import 'package:startlink/features/admin/data/repositories/admin_verification_repository_impl.dart';
import 'package:startlink/features/admin/domain/repositories/admin_verification_repository.dart';
import 'package:startlink/features/ai_co_founder/data/repositories/co_founder_repository_impl.dart';
import 'package:startlink/features/ai_co_founder/domain/repositories/co_founder_repository.dart';
import 'package:startlink/features/ai_co_founder/presentation/bloc/co_founder_bloc.dart';
import 'package:startlink/features/ai_insights/data/repositories/ai_insight_repository_impl.dart';
import 'package:startlink/features/ai_insights/domain/repositories/ai_insight_repository.dart';
import 'package:startlink/features/ai_insights/presentation/bloc/ai_insight_bloc.dart';
import 'package:startlink/features/aura/data/repositories/aura_repository_impl.dart';
import 'package:startlink/features/aura/domain/repositories/aura_repository.dart';
import 'package:startlink/features/aura/presentation/bloc/aura_bloc.dart';
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
import 'package:startlink/features/compass/data/repositories/compass_repository_impl.dart';
import 'package:startlink/features/compass/domain/repositories/compass_repository.dart';
import 'package:startlink/features/home/presentation/collaborator_dashboard.dart';
import 'package:startlink/features/home/presentation/innovator_dashboard.dart';
import 'package:startlink/features/home/presentation/investor_dashboard.dart';
import 'package:startlink/features/home/presentation/mentor_dashboard.dart';
import 'package:startlink/features/idea/data/repositories/idea_repository_impl.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/idea_dna/data/repositories/idea_dna_repository_impl.dart';
import 'package:startlink/features/idea_dna/domain/repositories/idea_dna_repository.dart';
import 'package:startlink/features/investor/data/repositories/interest_repository_impl.dart';
import 'package:startlink/features/investor/domain/repositories/interest_repository.dart';
import 'package:startlink/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/role_management/presentation/bloc/profile_gate_bloc.dart';
import 'package:startlink/features/role_management/presentation/bloc/profile_gate_event.dart';
import 'package:startlink/features/role_management/presentation/widgets/role_gate_wrapper.dart';
import 'package:startlink/features/trust/data/repositories/trust_repository_impl.dart';
import 'package:startlink/features/trust/domain/repositories/trust_repository.dart';
import 'package:startlink/features/trust/presentation/bloc/trust_score_bloc.dart';
import 'package:startlink/features/verification/data/repositories/verification_repository_impl.dart';
import 'package:startlink/features/verification/domain/repositories/verification_repository.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';

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
        RepositoryProvider<VerificationRepository>(
          create: (context) =>
              VerificationRepositoryImpl(supabase: SupabaseService.client),
        ),
        RepositoryProvider<AdminVerificationRepository>(
          create: (context) => AdminVerificationRepositoryImpl(),
        ),
        RepositoryProvider<TrustRepository>(
          create: (context) => TrustRepositoryImpl(),
        ),
        RepositoryProvider<InterestRepository>(
          create: (context) => InterestRepositoryImpl(),
        ),
        RepositoryProvider<AIInsightRepository>(
          create: (context) => AIInsightRepositoryImpl(),
        ),
        RepositoryProvider<AuraRepository>(
          create: (context) => AuraRepositoryImpl(),
        ),
        RepositoryProvider<AchievementRepository>(
          create: (context) => AchievementRepositoryImpl(),
        ),
        RepositoryProvider<CompassRepository>(
          create: (context) => CompassRepositoryImpl(),
        ),
        RepositoryProvider<CoFounderRepository>(
          create: (context) => CoFounderRepositoryImpl(),
        ),
        RepositoryProvider<IdeaDnaRepository>(
          create: (context) => IdeaDnaRepositoryImpl(),
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
          BlocProvider<ProfileGateBloc>(
            create: (context) => ProfileGateBloc(
              profileRepository: context.read<ProfileRepository>(),
            ),
          ),
          BlocProvider<MentorProfileBloc>(
            create: (context) => MentorProfileBloc(
              repository: context.read<ProfileRepository>(),
            ),
          ),
          BlocProvider<TrustScoreBloc>(
            create: (context) =>
                TrustScoreBloc(repository: context.read<TrustRepository>()),
          ),
          BlocProvider<AIInsightBloc>(
            create: (context) =>
                AIInsightBloc(repository: context.read<AIInsightRepository>()),
          ),
          BlocProvider<InvestorProfileBloc>(
            create: (context) => InvestorProfileBloc(
              repository: context.read<ProfileRepository>(),
            ),
          ),
          BlocProvider<AuraBloc>(
            create: (context) =>
                AuraBloc(repository: context.read<AuraRepository>()),
          ),
          BlocProvider<AchievementBloc>(
            create: (context) => AchievementBloc(
              repository: context.read<AchievementRepository>(),
            ),
          ),
          BlocProvider<VerificationBloc>(
            create: (context) => VerificationBloc(
              repository: context.read<VerificationRepository>(),
            ),
          ),
          BlocProvider<TrustScoreBloc>(
            create: (context) =>
                TrustScoreBloc(repository: context.read<TrustRepository>()),
          ),
          BlocProvider<CoFounderBloc>(
            create: (context) =>
                CoFounderBloc(repository: context.read<CoFounderRepository>()),
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Fetch user-specific data upon authentication
          context.read<ProfileBloc>().add(FetchProfile());
          context.read<IdeaBloc>().add(FetchIdeas());
          context.read<AuraBloc>().add(FetchAura(state.user.id));
          context.read<VerificationBloc>().add(
            FetchVerificationsAndBadges(state.user.id),
          );
          context.read<AchievementBloc>().add(FetchAchievements(state.user.id));
          // Add other fetches here if needed, e.g. Collaborations
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (authState is AuthAuthenticated) {
            return BlocConsumer<RoleBloc, RoleState>(
              // Changed to Consumer to listen for role changes
              listener: (context, roleState) {
                final userId = (authState).user.id;
                context.read<ProfileGateBloc>().add(
                  CheckProfileCompliance(
                    role: roleState.roleEnum,
                    userId: userId,
                  ),
                );
              },
              builder: (context, roleState) {
                if (roleState.activeRole.isNotEmpty) {
                  return RoleGateWrapper(
                    // Catch-all gate wrapper
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: KeyedSubtree(
                        key: ValueKey(roleState.activeRole),
                        child: _buildDashboard(roleState.activeRole),
                      ),
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
      ),
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
