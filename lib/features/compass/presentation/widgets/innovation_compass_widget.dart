import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/compass/domain/entities/compass_recommendation.dart';
import 'package:startlink/features/compass/domain/repositories/compass_repository.dart';
import 'package:startlink/features/compass/presentation/bloc/compass_bloc.dart';
import 'package:startlink/features/compass/presentation/bloc/compass_event.dart';
import 'package:startlink/features/compass/presentation/bloc/compass_state.dart';

class InnovationCompassWidget extends StatelessWidget {
  const InnovationCompassWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId == null) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) =>
          CompassBloc(repository: context.read<CompassRepository>())
            ..add(LoadCompass(userId)),
      child: const _CompassView(),
    );
  }
}

class _CompassView extends StatelessWidget {
  const _CompassView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CompassBloc, CompassState>(
      builder: (context, state) {
        if (state is CompassLoading) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CompassLoaded) {
          if (state.recommendations.isEmpty) {
            // If empty, show simplified state or nothing
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text('All clear! No immediate actions.'),
                  ],
                ),
              ),
            );
          }

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                  Theme.of(context).colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.explore, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Your Next Best Step',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.recommendations.map(
                  (rec) => _RecommendationTile(rec: rec),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _RecommendationTile extends StatelessWidget {
  final CompassRecommendation rec;
  const _RecommendationTile({required this.rec});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              _getIcon(rec.actionKey),
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                _buildBenefit(context, rec.expectedBenefit),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // Handle navigation logic based on actionKey
              _handleAction(context, rec.actionKey);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBenefit(BuildContext context, Map<String, dynamic> benefit) {
    if (benefit.isEmpty) return const SizedBox.shrink();

    final entries = benefit.entries
        .map((e) {
          final key = e.key[0].toUpperCase() + e.key.substring(1);
          return '+$key ${e.value}';
        })
        .join(' • ');

    return Text(
      entries,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade700,
      ),
    );
  }

  IconData _getIcon(String key) {
    if (key.contains('profile') ||
        key.contains('skills') ||
        key.contains('about')) {
      return Icons.person_outline;
    }
    if (key.contains('idea') || key.contains('clarify')) {
      return Icons.lightbulb_outline;
    }
    if (key.contains('link')) return Icons.link;
    return Icons.star_border;
  }

  void _handleAction(BuildContext context, String key) {
    if (key.contains('profile') ||
        key.contains('skills') ||
        key.contains('about') ||
        key.contains('link')) {
      // Navigate to Edit Profile
      // Assuming Route access or direct nav
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Navigate to Edit Profile')));
    } else if (key.contains('idea')) {
      // Navigate to Idea
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Navigate to Idea Form')));
    }
  }
}
