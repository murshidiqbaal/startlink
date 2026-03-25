import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/home/presentation/collaborator_dashboard.dart';
import 'package:startlink/features/home/presentation/innovator_dashboard.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import 'package:startlink/features/chat/presentation/bloc/chat_list_bloc.dart';
import 'package:startlink/features/messaging/presentation/bloc/conversation_bloc.dart';
import 'package:startlink/features/messaging/data/repositories/message_repositoy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppShell extends StatelessWidget {
  final String role;

  const AppShell({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            profileRepository: context.read<ProfileRepository>(),
          )..add(FetchProfile()),
        ),
        BlocProvider<RoleProfileBloc>(
          create: (context) => RoleProfileBloc(
            repository: context.read<ProfileRepository>(),
          )..add(LoadRoleProfile(
              profileId: userId,
              role: role.toLowerCase(),
            )),
        ),
        BlocProvider<ChatListBloc>(
          create: (context) => ChatListBloc(
            context.read<ChatRepository>(),
          ),
        ),
        BlocProvider<IdeaBloc>(
          create: (context) =>
              IdeaBloc(ideaRepository: context.read<IdeaRepository>())
                ..add(role == 'Innovator' ? FetchIdeas() : FetchPublicIdeas()),
        ),
        BlocProvider<CollaborationBloc>(
          create: (context) => CollaborationBloc(
            repository: context.read<CollaborationRepository>(),
          ),
        ),
        BlocProvider<ConversationBloc>(
          create: (context) => ConversationBloc(
            repository: MessageRepository(),
          ),
        ),
      ],
      child: _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    switch (role) {
      case 'Innovator':
        return InnovatorDashboard();
      case 'Collaborator':
        return CollaboratorDashboard();
      default:
        return InnovatorDashboard();
    }
  }
}
