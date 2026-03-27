import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_event.dart';

class MentorSetupScreen extends StatelessWidget {
  const MentorSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    // Trigger initial load for both blocs
    context.read<ProfileBloc>().add(FetchProfileById(userId));
    context.read<MentorProfileBloc>().add(LoadMentorProfile(userId));

    return const _MentorSetupForm();
  }
}

class _MentorSetupForm extends StatefulWidget {
  const _MentorSetupForm();

  @override
  State<_MentorSetupForm> createState() => _MentorSetupFormState();
}

class _MentorSetupFormState extends State<_MentorSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _yoeController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _expertiseController.dispose();
    _yoeController.dispose();
    _availabilityController.dispose();
    _linkedinController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Mentor Profile Setup', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocConsumer<MentorProfileBloc, MentorProfileState>(
        listener: (context, state) {
          if (state is MentorProfileLoaded) {
            _expertiseController.text = state.profile.expertise.join(', ');
            _yoeController.text = state.profile.yearsExperience?.toString() ?? '';
            _linkedinController.text = state.profile.linkedinUrl ?? '';
            _availabilityController.text = state.profile.availability ?? '';
          }
          if (state is MentorProfileSaved) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, pState) {
              if (pState is ProfileLoaded) {
                _nameController.text = pState.profile.fullName ?? '';
                // Only populate if bio is empty to avoid overwriting user edits
                if (_bioController.text.isEmpty) {
                  _bioController.text = pState.profile.about ?? '';
                }
              }

              final isLoading = state is MentorProfileLoading || pState is ProfileLoading;

              if (isLoading && _nameController.text.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildTextField('Full Name *', _nameController, Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Areas of Expertise *',
                        _expertiseController,
                        Icons.psychology_outlined,
                        hint: 'e.g. Marketing, Sales, Tech Architecture',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Years of Experience *',
                        _yoeController,
                        Icons.history_toggle_off_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Availability',
                        _availabilityController,
                        Icons.calendar_today_outlined,
                        hint: 'e.g. 2 hrs/week, Weekend mornings',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('LinkedIn URL *', _linkedinController, Icons.link),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Bio / Mentorship Philosophy *',
                        _bioController,
                        Icons.description_outlined,
                        maxLines: 4,
                        hint: 'How can you help growth-stage startups?',
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is MentorProfileSaving 
                            ? null 
                            : () => _handleSubmit(context, pState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: state is MentorProfileSaving
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text('Complete Onboarding', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mentorship Credentials',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Briefly share your background to unlock mentoring features and get your verified badge.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
            prefixIcon: Icon(icon, color: AppColors.brandPurple, size: 20),
            filled: true,
            fillColor: AppColors.surfaceGlass,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context, ProfileState pState) {
    if (_formKey.currentState!.validate()) {
      if (pState is! ProfileLoaded) return;
      
      final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;

      // Calculate completion for the mentor profile
      final expertise = _expertiseController.text.split(',').map((e) => e.trim()).toList();
      final bio = _bioController.text;
      final yoe = int.tryParse(_yoeController.text);
      final linkedin = _linkedinController.text;
      final availability = _availabilityController.text;

      final completion = MentorProfileModel.calculateCompletion(
        expertise: expertise,
        yearsExperience: yoe,
        bio: bio,
        linkedinUrl: linkedin,
        availability: availability,
      );

      final mentorProfile = MentorProfileModel(
        profileId: userId,
        expertise: expertise,
        yearsExperience: yoe,
        bio: bio,
        linkedinUrl: linkedin,
        availability: availability,
        profileCompletion: completion,
      );

      final updatedBase = pState.profile.copyWith(
        fullName: _nameController.text,
        about: bio, // Sync mentor bio to base profile about
      );

      context.read<MentorProfileBloc>().add(
        UpdateConsolidatedProfile(
          baseProfile: updatedBase,
          mentorProfile: mentorProfile,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated! Verification will trigger if completion ≥ 80%.'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
