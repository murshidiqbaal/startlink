import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/presentation/widgets/startlink_button.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/chat/domain/repositories/chat_repository.dart';
import 'package:startlink/features/chat/presentation/screens/chat_screen.dart';
import 'package:startlink/features/collaboration/presentation/pages/idea_applications_screen.dart';
import 'package:startlink/features/collaboration/presentation/widgets/apply_collaboration_dialog.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/presentation/idea_post_screen.dart';
import 'package:startlink/features/idea_dna/domain/repositories/idea_dna_repository.dart';
import 'package:startlink/features/idea_dna/presentation/bloc/idea_dna_bloc.dart';
import 'package:startlink/features/idea_dna/presentation/widgets/idea_dna_card.dart';

class IdeaDetailScreen extends StatelessWidget {
  final Idea idea;

  const IdeaDetailScreen({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          IdeaDnaBloc(repository: context.read<IdeaDnaRepository>())
            ..add(FetchIdeaDna(idea.id)),
      child: _IdeaDetailView(idea: idea),
    );
  }
}

class _IdeaDetailView extends StatelessWidget {
  final Idea idea;

  const _IdeaDetailView({required this.idea});

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.client.auth.currentUser?.id;
    final isOwner = currentUserId == idea.ownerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: idea.coverImageUrl != null
                  ? Image.network(idea.coverImageUrl!, fit: BoxFit.cover)
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.brandPurple.withValues(alpha: 0.3),
                            AppColors.background,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TaskBadge(status: idea.status),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.brandCyan.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          idea.currentStage,
                          style: const TextStyle(
                            color: AppColors.brandCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    idea.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    idea.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  if (idea.problemStatement.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _Header('Problem Statement'),
                    Text(
                      idea.problemStatement,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  if (idea.targetMarket.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _Header('Target Market'),
                    Text(
                      idea.targetMarket,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                  _Header('Startup DNA'),
                  IdeaDnaCard(ideaId: idea.id),

                  const SizedBox(height: 32),
                  _Header('Business Info'),
                  _InfoRow(
                    label: 'Industry',
                    value:
                        '${idea.industry}${idea.subIndustry != null ? " (${idea.subIndustry})" : ""}',
                    icon: Icons.factory_outlined,
                  ),
                  _InfoRow(
                    label: 'Business Model',
                    value: idea.businessModel ?? 'N/A',
                    icon: Icons.account_balance_outlined,
                  ),
                  _InfoRow(
                    label: 'Location',
                    value: idea.location ?? 'Remote',
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 32),
                  _Header('Funding & Team'),
                  Row(
                    children: [
                      _StatCard(
                        label: 'Funding Needed',
                        value:
                            '\$${idea.fundingNeeded?.toStringAsFixed(0) ?? "0"}',
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Equity Offered',
                        value:
                            '${idea.equityOffered?.toStringAsFixed(1) ?? "0"}%',
                        icon: Icons.pie_chart_outline,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Team Size',
                    value: '${idea.teamSize} members',
                    icon: Icons.groups_2_outlined,
                  ),

                  const SizedBox(height: 32),
                  _Header('Required Skills'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: idea.tags.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40),
                  // Actions
                  Row(
                    children: [
                      if (isOwner)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      IdeaPostScreen(idea: idea),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Edit Idea'),
                          ),
                        ),
                      if (isOwner) const SizedBox(width: 16),
                      Expanded(
                        child: StartLinkButton(
                          label: isOwner
                              ? 'View Applications'
                              : 'Apply as Collaborator',
                          onPressed: () {
                            if (isOwner) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IdeaApplicationsScreen(
                                    ideaId: idea.id,
                                    ideaTitle: idea.title,
                                  ),
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (dialogContext) => BlocProvider.value(
                                  value: context.read<CollaborationBloc>(),
                                  child: ApplyCollaborationDialog(
                                      idea: idea),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Chat Button (Visible to Owner or Accepted Collaborators)
                  IdeaChatButton(idea: idea),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.brandCyan),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskBadge extends StatelessWidget {
  final String status;

  const _TaskBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'open':
        color = Colors.green;
        break;
      case 'closed':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class IdeaChatButton extends StatelessWidget {
  final Idea idea;

  const IdeaChatButton({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final currentUserId = SupabaseService.client.auth.currentUser?.id;
    if (currentUserId == null) return const SizedBox.shrink();

    // The owner is always a team member
    if (currentUserId == idea.ownerId) {
      return _buildButton(context);
    }

    return FutureBuilder<bool>(
      future: context.read<ChatRepository>().isTeamMember(
        idea.id,
        currentUserId,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return _buildButton(context);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            try {
              final chatRepo = context.read<ChatRepository>();
              final roomId = await chatRepo.getOrCreateRoom(idea.id);
              
              if (!context.mounted) return;
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    roomId: roomId,
                    ideaTitle: idea.title,
                  ),
                ),
              );
            } catch (e) {
              scaffoldMessenger.showSnackBar(
                SnackBar(content: Text('Error opening chat: $e')),
              );
            }
          },
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text('Open Team Chat'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.brandCyan,
            side: const BorderSide(color: AppColors.brandCyan),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
