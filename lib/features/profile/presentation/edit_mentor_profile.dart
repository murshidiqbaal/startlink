import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';

class EditMentorProfileScreen extends StatelessWidget {
  const EditMentorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = context.read<AuthBloc>().state is AuthAuthenticated
            ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
            : '';
        return MentorProfileBloc(repository: context.read<ProfileRepository>())
          ..add(LoadMentorProfile(userId));
      },
      child: const _EditMentorForm(),
    );
  }
}

class _EditMentorForm extends StatefulWidget {
  const _EditMentorForm();

  @override
  State<_EditMentorForm> createState() => _EditMentorFormState();
}

class _EditMentorFormState extends State<_EditMentorForm> {
  final _formKey = GlobalKey<FormState>();
  final _expertiseController = TextEditingController();
  final _yoeController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _focusController = TextEditingController();

  @override
  void dispose() {
    _expertiseController.dispose();
    _yoeController.dispose();
    _linkedinController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Mentor Profile')),
      body: BlocConsumer<MentorProfileBloc, MentorProfileState>(
        listener: (context, state) {
          if (state is MentorProfileLoaded) {
            if (_expertiseController.text.isEmpty) {
              _expertiseController.text = state.profile.expertiseDomains.join(
                ', ',
              );
            }
            if (_yoeController.text.isEmpty &&
                state.profile.yearsOfExperience != null) {
              _yoeController.text = state.profile.yearsOfExperience.toString();
            }
            if (_linkedinController.text.isEmpty) {
              _linkedinController.text = state.profile.linkedinUrl ?? '';
            }
            if (_focusController.text.isEmpty) {
              _focusController.text = state.profile.mentorshipFocus ?? '';
            }
          }
          if (state is MentorProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is MentorProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MentorProfileLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _expertiseController,
                      decoration: const InputDecoration(
                        labelText: 'Expertise Domains (comma separated)',
                        hintText: 'Marketing, Tech, Sales',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _yoeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _linkedinController,
                      decoration: const InputDecoration(
                        labelText: 'LinkedIn URL',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _focusController,
                      decoration: const InputDecoration(
                        labelText: 'Mentorship Focus',
                        hintText: 'Career growth, Startups',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final expertise = _expertiseController.text
                              .split(',')
                              .map((e) => e.trim())
                              .where((e) => e.isNotEmpty)
                              .toList();

                          final updatedProfile = MentorProfile(
                            profileId: state.profile.profileId,
                            expertiseDomains: expertise,
                            yearsOfExperience:
                                int.tryParse(_yoeController.text) ?? 0,
                            linkedinUrl: _linkedinController.text,
                            mentorshipFocus: _focusController.text,
                          );

                          context.read<MentorProfileBloc>().add(
                            SaveMentorProfile(updatedProfile),
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
