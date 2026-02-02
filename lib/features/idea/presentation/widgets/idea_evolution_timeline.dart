import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/features/idea/domain/entities/idea_activity_log.dart';
import 'package:startlink/features/idea/domain/repositories/idea_activity_repository.dart';
import 'package:startlink/features/idea/domain/services/idea_activity_logger.dart';
import 'package:startlink/features/idea/presentation/bloc/activity/idea_activity_bloc.dart';
import 'package:startlink/features/idea/presentation/bloc/activity/idea_activity_event.dart';
import 'package:startlink/features/idea/presentation/bloc/activity/idea_activity_state.dart';

class IdeaEvolutionTimeline extends StatelessWidget {
  final String ideaId;
  final IdeaActivityRepository repository;

  const IdeaEvolutionTimeline({
    super.key,
    required this.ideaId,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          IdeaActivityBloc(repository)..add(LoadIdeaActivity(ideaId)),
      child: const _TimelineView(),
    );
  }
}

class _TimelineView extends StatelessWidget {
  const _TimelineView();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'IDEA EVOLUTION',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        BlocBuilder<IdeaActivityBloc, IdeaActivityState>(
          builder: (context, state) {
            if (state is IdeaActivityLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is IdeaActivityError) {
              return Text('Error: ${state.message}');
            } else if (state is IdeaActivityLoaded) {
              if (state.logs.isEmpty) {
                return const Text('No activity yet.');
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.logs.length,
                itemBuilder: (context, index) {
                  final log = state.logs[index];
                  final isLast = index == state.logs.length - 1;
                  return _TimelineItem(log: log, isLast: isLast);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IdeaActivityLog log;
  final bool isLast;

  const _TimelineItem({required this.log, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getEventColor(
                    context,
                    log.eventType,
                  ).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _getEventIcon(log.eventType),
                    size: 16,
                    color: _getEventColor(context, log.eventType),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (log.description != null)
                    Text(
                      log.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                  const SizedBox(height: 4),
                  if (log.metadata.containsKey('delta'))
                    Text(
                      '${log.metadata['delta'] > 0 ? '+' : ''}${log.metadata['delta']}%',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),

                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(log.createdAt), // Date
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case IdeaActivityLogger.ideaCreated:
        return Icons.lightbulb_outline;
      case IdeaActivityLogger.ideaPublished:
        return Icons.rocket_launch;
      case IdeaActivityLogger.mentorFeedbackAdded:
        return Icons.psychology;
      case IdeaActivityLogger.profileImproved:
        return Icons.edit_note;
      case IdeaActivityLogger.confidenceIncreased:
        return Icons.trending_up;
      case IdeaActivityLogger.investorInterest:
        return Icons.monetization_on;
      case IdeaActivityLogger.collaborationStarted:
        return Icons.handshake;
      case IdeaActivityLogger.milestoneAchieved:
        return Icons.emoji_events;
      default:
        return Icons.circle;
    }
  }

  Color _getEventColor(BuildContext context, String eventType) {
    switch (eventType) {
      case IdeaActivityLogger.ideaCreated:
        return Colors.green;
      case IdeaActivityLogger.ideaPublished:
        return Colors.blue;
      case IdeaActivityLogger.mentorFeedbackAdded:
        return Colors.purple;
      case IdeaActivityLogger.confidenceIncreased:
        return Colors.orange;
      case IdeaActivityLogger.investorInterest:
        return Colors.amber;
      case IdeaActivityLogger.collaborationStarted:
        return Colors.teal;
      case IdeaActivityLogger.milestoneAchieved:
        return Colors.amber;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }
}
