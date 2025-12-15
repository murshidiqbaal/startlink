import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_form_bloc.dart';

class IdeaPostScreen extends StatelessWidget {
  final Idea? idea;
  const IdeaPostScreen({super.key, this.idea});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          IdeaFormBloc(ideaRepository: context.read<IdeaRepository>())
            ..add(InitializeForm(idea)),
      child: _IdeaPostView(idea: idea),
    );
  }
}

class _IdeaPostView extends StatefulWidget {
  final Idea? idea;
  const _IdeaPostView({this.idea});

  @override
  State<_IdeaPostView> createState() => _IdeaPostViewState();
}

class _IdeaPostViewState extends State<_IdeaPostView> {
  final _formKey = GlobalKey<FormState>();
  final _skillController = TextEditingController();

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IdeaFormBloc, IdeaFormState>(
      listener: (context, state) {
        if (state.status == IdeaFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state.status == IdeaFormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isDraft
                    ? 'Idea saved as draft!'
                    : (state.isEditing
                          ? 'Idea updated successfully!'
                          : 'Idea published successfully!'),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to trigger refresh
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(state.isEditing ? 'Edit Idea' : 'Post New Idea'),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(context, '1. Function Basics'),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Idea Title *',
                          hintText: 'e.g., Solar-Powered Drone',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 80,
                        onChanged: (value) => context.read<IdeaFormBloc>().add(
                          TitleChanged(value),
                        ),
                        validator: (value) =>
                            value?.isEmpty ?? true ? 'Title is required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Short Description *',
                          hintText: 'A brief overview of your idea...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        onChanged: (value) => context.read<IdeaFormBloc>().add(
                          DescriptionChanged(value),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Problem Statement *',
                          hintText: 'What problem are you solving?',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 3,
                        onChanged: (value) => context.read<IdeaFormBloc>().add(
                          ProblemStatementChanged(value),
                        ),
                        validator: (value) => value?.isEmpty ?? true
                            ? 'Problem statement is required'
                            : null,
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, '2. Idea Details'),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Target Market',
                          hintText: 'e.g., Small Business Owners, Gen Z',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) => context.read<IdeaFormBloc>().add(
                          TargetMarketChanged(value),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: state.currentStage,
                        decoration: const InputDecoration(
                          labelText: 'Current Stage',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Idea', 'Prototype', 'MVP', 'Scaling']
                            .map(
                              (stage) => DropdownMenuItem(
                                value: stage,
                                child: Text(stage),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<IdeaFormBloc>().add(
                              CurrentStageChanged(value),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildSkillsInput(context, state),
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, '3. Visibility & Actions'),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Public Visibility'),
                        subtitle: const Text(
                          'Allow everyone to see this idea. If off, it will be private.',
                        ),
                        value: state.isPublic,
                        onChanged: (value) => context.read<IdeaFormBloc>().add(
                          VisibilityChanged(value),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: state.status == IdeaFormStatus.loading
                                  ? null
                                  : () {
                                      context.read<IdeaFormBloc>().add(
                                        SaveDraft(),
                                      );
                                    },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Save as Draft'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: state.status == IdeaFormStatus.loading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        context.read<IdeaFormBloc>().add(
                                          PublishIdea(),
                                        );
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                state.isEditing
                                    ? 'Update Idea'
                                    : 'Publish Idea',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (state.status == IdeaFormStatus.loading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSkillsInput(BuildContext context, IdeaFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                decoration: const InputDecoration(
                  labelText: 'Required Skills (Add)',
                  hintText: 'e.g., Flutter',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    final newSkills = List<String>.from(state.skills)
                      ..add(value);
                    context.read<IdeaFormBloc>().add(SkillsChanged(newSkills));
                    _skillController.clear();
                  }
                },
              ),
            ),
            IconButton(
              onPressed: () {
                if (_skillController.text.isNotEmpty) {
                  final newSkills = List<String>.from(state.skills)
                    ..add(_skillController.text);
                  context.read<IdeaFormBloc>().add(SkillsChanged(newSkills));
                  _skillController.clear();
                }
              },
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: state.skills.map((skill) {
            return Chip(
              label: Text(skill),
              onDeleted: () {
                final newSkills = List<String>.from(state.skills)
                  ..remove(skill);
                context.read<IdeaFormBloc>().add(SkillsChanged(newSkills));
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
