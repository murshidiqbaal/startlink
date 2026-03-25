import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/matching/data/repositories/matching_repository_impl.dart';
import 'package:startlink/features/matching/domain/entities/idea_match.dart';
import 'package:startlink/features/matching/presentation/bloc/matching_bloc.dart';
import 'package:startlink/features/matching/presentation/bloc/matching_event.dart';
import 'package:startlink/features/matching/presentation/bloc/matching_state.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

class RecommendedMatchesWidget extends StatelessWidget {
  final Idea idea;
  const RecommendedMatchesWidget({super.key, required this.idea});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MatchingBloc(repository: MatchingRepositoryImpl())
            ..add(LoadMatches(idea)),
      child: const _MatchesView(),
    );
  }
}

class _MatchesView extends StatelessWidget {
  const _MatchesView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchingBloc, MatchingState>(
      builder: (context, state) {
        if (state is MatchingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MatchingLoaded) {
          if (state.mentors.isEmpty && state.collaborators.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              if (state.mentors.isNotEmpty) ...[
                _buildSectionTitle(context, '🎓 Mentors matched for you'),
                const SizedBox(height: 8),
                ...state.mentors.take(3).map((m) => _MatchCard(match: m)),
                const SizedBox(height: 16),
              ],

              if (state.collaborators.isNotEmpty) ...[
                _buildSectionTitle(context, '👥 Suggested Collaborators'),
                const SizedBox(height: 8),
                ...state.collaborators.take(3).map((m) => _MatchCard(match: m)),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Smart Recommendations',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final IdeaMatch match;
  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProfileScreen(userId: match.matchedProfileId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: match.matchedProfileAvatarUrl != null
                    ? NetworkImage(match.matchedProfileAvatarUrl!)
                    : null,
                child: match.matchedProfileAvatarUrl == null
                    ? Text(match.matchedProfileName[0].toUpperCase())
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          match.matchedProfileName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(
                              match.matchScore,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${match.matchScore}% Match',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(match.matchScore),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildReason(context, match.matchReason),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReason(BuildContext context, Map<String, dynamic> reason) {
    final List<String> reasons = [];

    // Skills
    if (reason['skills'] != null) {
      final skills = (reason['skills'] as List).cast<String>();
      if (skills.isNotEmpty) {
        reasons.add('Skills: ${skills.join(", ")}');
      }
    }

    // Trust
    if (reason['trust_reason'] != null &&
        reason['trust_reason'].toString().isNotEmpty) {
      reasons.add(reason['trust_reason']);
    }

    // Activity
    if (reason['activity_reason'] != null &&
        reason['activity_reason'].toString().isNotEmpty) {
      reasons.add('⚡ ${reason['activity_reason']}');
    }

    if (reasons.isEmpty) return const SizedBox.shrink();

    return Text(
      reasons.join(" • "),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: Theme.of(context).disabledColor),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.blue;
    return Colors.orange;
  }
}
