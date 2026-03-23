import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/matching/presentation/widgets/recommended_matches_widget.dart';

class MatchingPage extends StatelessWidget {
  const MatchingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Co-Founders')),
      body: BlocBuilder<IdeaBloc, IdeaState>(
        builder: (context, state) {
          if (state is IdeaLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is IdeaLoaded) {
            if (state.ideas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text('Post an idea to start matching!'),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.ideas.length,
              itemBuilder: (context, index) {
                final idea = state.ideas[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IdeaCard(
                    title: idea.title,
                    description: idea.description,
                    status: idea.status,
                    // We use IdeaCard but override onTap to go to matching
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: Text('Matches for ${idea.title}'),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(16),
                              child: RecommendedMatchesWidget(idea: idea),
                            ),
                          ),
                        ),
                      );
                    },
                    skills: idea.tags ?? [],
                    imageUrl: idea.coverImageUrl,
                    views: 0,
                    applications: 0,
                  ),
                );
              },
            );
          }
          // Trigger fetch if not loaded? The global IdeaBloc likely has it.
          // If not, we could context.read<IdeaBloc>().add(FetchIdeas());
          // but normally main dashboard does it.
          return const Center(child: Text('Check your connection'));
        },
      ),
    );
  }
}
