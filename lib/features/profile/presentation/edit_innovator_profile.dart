import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/innovator_profile_bloc.dart';

class EditInnovatorProfileScreen extends StatelessWidget {
  const EditInnovatorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = context.read<AuthBloc>().state is AuthAuthenticated
            ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
            : '';
        return InnovatorProfileBloc(
          repository: context.read<ProfileRepository>(),
        )..add(LoadInnovatorProfile(userId));
      },
      child: const _EditInnovatorForm(),
    );
  }
}

class _EditInnovatorForm extends StatefulWidget {
  const _EditInnovatorForm();

  @override
  State<_EditInnovatorForm> createState() => _EditInnovatorFormState();
}

class _EditInnovatorFormState extends State<_EditInnovatorForm> {
  final _formKey = GlobalKey<FormState>();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();

  @override
  void dispose() {
    _skillsController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Innovator Profile')),
      body: BlocConsumer<InnovatorProfileBloc, InnovatorProfileState>(
        listener: (context, state) {
          if (state is InnovatorProfileLoaded) {
            if (_skillsController.text.isEmpty) {
              _skillsController.text = state.profile.skills.join(', ');
            }
            if (_experienceController.text.isEmpty) {
              _experienceController.text = state.profile.experienceLevel ?? '';
            }
            if (_educationController.text.isEmpty) {
              _educationController.text = state.profile.education ?? '';
            }
          }
          if (state is InnovatorProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is InnovatorProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InnovatorProfileLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _skillsController,
                      decoration: const InputDecoration(
                        labelText: 'Skills (comma separated)',
                        hintText: 'Flutter, Dart, Firebase',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _experienceController,
                      decoration: const InputDecoration(
                        labelText: 'Experience Level',
                        hintText: 'Junior, Mid, Senior',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _educationController,
                      decoration: const InputDecoration(labelText: 'Education'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final skills = _skillsController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          final updatedProfile = InnovatorProfile(
                            profileId: state.profile.profileId,
                            skills: skills,
                            experienceLevel: _experienceController.text,
                            education: _educationController.text,
                            // completion updated by backend or calc logic on save
                          );

                          context.read<InnovatorProfileBloc>().add(
                            SaveInnovatorProfile(updatedProfile),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Save Profile'),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: Text('Failed to load profile'));
        },
      ),
    );
  }
}
