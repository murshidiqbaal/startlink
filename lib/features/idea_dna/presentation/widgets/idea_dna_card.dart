import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/ai_co_founder/presentation/pages/co_founder_chat_screen.dart';
import 'package:startlink/features/idea_dna/domain/entities/idea_dna.dart';
import 'package:startlink/features/idea_dna/presentation/bloc/idea_dna_bloc.dart';
import 'package:startlink/features/idea_dna/presentation/widgets/dna_ring_painter.dart';

class IdeaDnaCard extends StatelessWidget {
  final String ideaId;

  const IdeaDnaCard({super.key, required this.ideaId});

  @override
  Widget build(BuildContext context) {
    // Note: Ensure IdeaDnaBloc is provided in the parent tree or inject it here.
    return BlocConsumer<IdeaDnaBloc, IdeaDnaState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is IdeaDnaLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is IdeaDnaLoaded) {
          return _buildCardContent(context, state.dna);
        } else if (state is IdeaDnaError) {
          // Fallback or retry UI
          return Center(
            child: Text('DNA Analysis Unavailable: ${state.message}'),
          );
        }
        return const SizedBox.shrink(); // Initial state
      },
    );
  }

  Widget _buildCardContent(BuildContext context, IdeaDna dna) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 2;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildDimensionTile(
                    context,
                    'Market',
                    dna.market,
                    Colors.cyan,
                    itemWidth,
                  ),
                  _buildDimensionTile(
                    context,
                    'Innovation',
                    dna.innovation,
                    Colors.purpleAccent,
                    itemWidth,
                  ),
                  _buildDimensionTile(
                    context,
                    'Risk',
                    dna.risk,
                    Colors.orangeAccent,
                    itemWidth,
                  ),
                  _buildDimensionTile(
                    context,
                    'Revenue',
                    dna.revenue,
                    AppColors.emerald,
                    itemWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.fingerprint, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'Idea DNA',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'AI Analyzed',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined, size: 20),
          tooltip: 'Discuss with AI Co-Founder',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CoFounderChatScreen(contextId: ideaId),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDimensionTile(
    BuildContext context,
    String label,
    DnaDimension dimension,
    Color color,
    double width,
  ) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          SizedBox(
            height: 80,
            width: 80,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: dimension.score / 100),
              duration: const Duration(seconds: 2),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(80, 80),
                      painter: DnaRingPainter(
                        progress: value,
                        color: color,
                        strokeWidth: 6,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          (value * 100).toInt().toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          // Sub-metrics (simplified bar)
          ...dimension.metrics
              .take(2)
              .map(
                (m) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          m.label,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 30,
                        height: 3,
                        child: LinearProgressIndicator(
                          value: m.value / 100,
                          backgroundColor: color.withValues(alpha: 0.1),
                          valueColor: AlwaysStoppedAnimation(color),
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
}
