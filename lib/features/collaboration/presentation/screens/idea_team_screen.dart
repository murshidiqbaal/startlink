import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/domain/entities/idea_team_member.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';

class IdeaTeamScreen extends StatefulWidget {
  final String ideaId;
  final String ideaTitle;

  const IdeaTeamScreen({
    super.key,
    required this.ideaId,
    required this.ideaTitle,
  });

  @override
  State<IdeaTeamScreen> createState() => _IdeaTeamScreenState();
}

class _IdeaTeamScreenState extends State<IdeaTeamScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CollaborationBloc>().add(FetchIdeaTeamMembers(widget.ideaId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.ideaTitle} Team'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocBuilder<CollaborationBloc, CollaborationState>(
        builder: (context, state) {
          if (state is CollaborationLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            );
          }

          if (state is IdeaTeamMembersLoaded) {
            final members = state.members;

            if (members.isEmpty) {
              return const Center(
                child: Text(
                  'No team members yet.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<CollaborationBloc>()
                    .add(FetchIdeaTeamMembers(widget.ideaId));
              },
              color: AppColors.brandPurple,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _TeamMemberCard(member: members[index]);
                },
              ),
            );
          }

          if (state is CollaborationError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppColors.rose),
              ),
            );
          }

          return const Center(
            child: Text(
              'Something went wrong.',
              style: TextStyle(color: AppColors.rose),
            ),
          );
        },
      ),
    );
  }
}

class _TeamMemberCard extends StatelessWidget {
  final IdeaTeamMember member;

  const _TeamMemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.1),
            backgroundImage: member.avatarUrl != null && member.avatarUrl!.isNotEmpty
                ? NetworkImage(member.avatarUrl!)
                : null,
            child: (member.avatarUrl == null || member.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: AppColors.textSecondary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandCyan.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    member.role,
                    style: const TextStyle(
                      color: AppColors.brandCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
