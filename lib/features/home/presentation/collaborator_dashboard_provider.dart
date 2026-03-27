import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/home/presentation/collaborator_dashboard.dart';

class CollaboratorDashboardProvider extends StatelessWidget {
  const CollaboratorDashboardProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RoleProfileBloc>(
          create: (context) => RoleProfileBloc(
            repository: context.read<ProfileRepository>(),
            authRepository: context.read<AuthRepository>(),
          )..add(const LoadRoleProfile(role: 'collaborator')),
        ),
        BlocProvider<ChatListBloc>(
          create: (context) => ChatListBloc(
            context.read<ChatRepository>(),
          ),
        ),
        BlocProvider<IdeaBloc>(
          create: (context) => IdeaBloc(
            ideaRepository: context.read<IdeaRepository>(),
          )..add(FetchPublicIdeas()),
        ),
        BlocProvider<CollaborationBloc>(
          create: (context) => CollaborationBloc(
            repository: context.read<CollaborationRepository>(),
          ),
        ),
      ],
      child: CollaboratorDashboard(),
    );
  }
}
