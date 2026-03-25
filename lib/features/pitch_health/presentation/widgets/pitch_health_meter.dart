import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/pitch_health/data/repositories/pitch_health_repository.dart';
import 'package:startlink/features/pitch_health/presentation/bloc/pitch_health_bloc.dart';

class PitchHealthMeter extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descController;

  const PitchHealthMeter({
    super.key,
    required this.titleController,
    required this.descController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = PitchHealthBloc(repository: PitchHealthRepositoryImpl());

        // Listen to controllers
        void listener() {
          bloc.add(
            AnalyzePitch(
              title: titleController.text,
              description: descController.text,
            ),
          );
        }

        titleController.addListener(listener);
        descController.addListener(listener);

        return bloc;
      },
      child: const _MeterView(),
    );
  }
}

class _MeterView extends StatelessWidget {
  const _MeterView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PitchHealthBloc, PitchHealthState>(
      builder: (context, state) {
        int score = 0;
        Color color = Colors.grey;

        if (state is PitchHealthLoaded) {
          score = state.score.overallScore;
          color = _getColor(score);
        } else if (state is PitchHealthLoading) {
          // Keep previous score or show loading indicator subtly
          // For now, let's just make the meter pulsating or grey
          color = Colors.blueGrey;
        }

        return Container(
          width: 60, // Slim vertical meter
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.speed, size: 16, color: Colors.grey),
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: 10,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  height: score.toDouble(), // 0-100 map directly to height
                  width: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [color.withValues(alpha: 0.7), color],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$score',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getColor(int score) {
    if (score < 40) return Colors.red;
    if (score < 70) return Colors.orange;
    return Colors.green;
  }
}
