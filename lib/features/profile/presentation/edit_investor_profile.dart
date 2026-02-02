import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';

class EditInvestorProfileScreen extends StatelessWidget {
  const EditInvestorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final userId = context.read<AuthBloc>().state is AuthAuthenticated
            ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
            : '';
        return InvestorProfileBloc(
          repository: context.read<ProfileRepository>(),
        )..add(LoadInvestorProfile(userId));
      },
      child: const _EditInvestorForm(),
    );
  }
}

class _EditInvestorForm extends StatefulWidget {
  const _EditInvestorForm();

  @override
  State<_EditInvestorForm> createState() => _EditInvestorFormState();
}

class _EditInvestorFormState extends State<_EditInvestorForm> {
  final _formKey = GlobalKey<FormState>();
  final _focusController = TextEditingController();
  final _minTicketController = TextEditingController();
  final _maxTicketController = TextEditingController();
  final _stageController = TextEditingController();
  final _orgController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void dispose() {
    _focusController.dispose();
    _minTicketController.dispose();
    _maxTicketController.dispose();
    _stageController.dispose();
    _orgController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Investor Profile')),
      body: BlocConsumer<InvestorProfileBloc, InvestorProfileState>(
        listener: (context, state) {
          if (state is InvestorProfileLoaded) {
            if (_focusController.text.isEmpty) {
              _focusController.text = state.profile.investmentFocus ?? '';
            }
            if (_minTicketController.text.isEmpty &&
                state.profile.ticketSizeMin != null) {
              _minTicketController.text = state.profile.ticketSizeMin
                  .toString();
            }
            if (_maxTicketController.text.isEmpty &&
                state.profile.ticketSizeMax != null) {
              _maxTicketController.text = state.profile.ticketSizeMax
                  .toString();
            }
            if (_stageController.text.isEmpty) {
              _stageController.text = state.profile.preferredStage ?? '';
            }
            if (_orgController.text.isEmpty) {
              _orgController.text = state.profile.organizationName ?? '';
            }
            if (_linkedinController.text.isEmpty) {
              _linkedinController.text = state.profile.linkedinUrl ?? '';
            }
          }
          if (state is InvestorProfileError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is InvestorProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InvestorProfileLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _focusController,
                      decoration: const InputDecoration(
                        labelText: 'Investment Focus',
                        hintText: 'SaaS, Fintech, Health',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _minTicketController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Min Ticket Size (\$)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _maxTicketController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Max Ticket Size (\$)',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stageController,
                      decoration: const InputDecoration(
                        labelText: 'Preferred Stage',
                        hintText: 'Pre-Seed, Seed, Series A',
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _orgController,
                      decoration: const InputDecoration(
                        labelText: 'Organization Name',
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedProfile = InvestorProfile(
                            profileId: state.profile.profileId,
                            investmentFocus: _focusController.text,
                            ticketSizeMin: double.tryParse(
                              _minTicketController.text,
                            ),
                            ticketSizeMax: double.tryParse(
                              _maxTicketController.text,
                            ),
                            preferredStage: _stageController.text,
                            organizationName: _orgController.text,
                            linkedinUrl: _linkedinController.text,
                          );

                          context.read<InvestorProfileBloc>().add(
                            SaveInvestorProfile(updatedProfile),
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
