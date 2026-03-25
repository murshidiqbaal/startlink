import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/ai_feedback/presentation/widgets/ai_info_tooltip.dart';
import 'package:startlink/features/ai_insights/presentation/widgets/ai_insight_card.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/idea/data/repositories/idea_activity_repository_impl.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/presentation/widgets/idea_evolution_timeline.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_interest_bloc.dart';
import 'package:startlink/features/matching/presentation/widgets/recommended_matches_widget.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

class InvestorIdeaDetailScreen extends StatelessWidget {
  final Idea idea;

  const InvestorIdeaDetailScreen({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AuthRepository>().currentUser?.id ?? '';

    // Check initial status for UI consistency
    // Note: Ideally pass initial state or fetch in initState, but Bloc handles updates reactive

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Opportunity'),
        actions: [
          const AIInfoTooltip(),
          BlocBuilder<InvestorInterestBloc, InvestorInterestState>(
            builder: (context, state) {
              bool isBookmarked = false;
              if (state is InvestorInterestLoaded) {
                isBookmarked = state.isBookmarked(idea.id);
              }
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                ),
                onPressed: () {
                  context.read<InvestorInterestBloc>().add(
                    BookmarkIdea(ideaId: idea.id, investorId: currentUserId),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Badges
            Row(
              children: [
                Expanded(
                  child: Text(
                    idea.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (idea.isVerified) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.verified, color: Colors.blue),
                ],
              ],
            ),

            if (idea.id == 'boosted' ||
                (idea.isPublic && idea.viewCount > 100)) ...[
              // Simplified boost check if boost logic not fully in entity yet (repo sort uses score)
              // Assuming is_boosted field comes through Idea entity eventually.
              // For now, if passed via list, we trust list order.
              // Visual placeholder for now if entity doesn't have isBoosted explicit field in Dart yet (repo sql has it)
            ],

            const SizedBox(height: 16),

            // AI Summary
            if (idea.aiSummary != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Summary',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      idea.aiSummary!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // AI Investment Insights Section
            AIInsightCard(ideaId: idea.id),

            const SizedBox(height: 24),
            _buildSection(context, 'Problem Statement', idea.problemStatement),
            const SizedBox(height: 16),
            _buildSection(context, 'Description', idea.description),
            const SizedBox(height: 24),

            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Details',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Stage', idea.currentStage),
            _buildDetailRow(context, 'Target Market', idea.targetMarket),
            _buildDetailRow(
              context,
              'Skills Required',
              idea.tags.join(', '),
            ), // skills mapped to tags currently

            const SizedBox(height: 32),
            Text(
              'Innovator',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text('U'),
              ), // Placeholder/Initials from ownerId fetch if feasible
              title: const Text('Innovator Profile'), // Ideally fetch real name
              subtitle: const Text('View full credentials & trust score'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(userId: idea.ownerId),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            RecommendedMatchesWidget(idea: idea),
            IdeaEvolutionTimeline(
              ideaId: idea.id,
              repository: IdeaActivityRepositoryImpl(),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: BlocBuilder<InvestorInterestBloc, InvestorInterestState>(
                builder: (context, state) {
                  bool isInterested = false;
                  if (state is InvestorInterestLoaded) {
                    isInterested = state.isInterested(idea.id);
                  }

                  return FilledButton.icon(
                    onPressed: () {
                      context.read<InvestorInterestBloc>().add(
                        ExpressInterest(
                          ideaId: idea.id,
                          investorId: currentUserId,
                        ),
                      );
                    },
                    icon: Icon(isInterested ? Icons.check : Icons.thumb_up),
                    label: Text(
                      isInterested ? 'Interest Expressed' : 'Express Interest',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: isInterested ? Colors.green : null,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
