import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_event.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';

class MentorSetupScreen extends StatelessWidget {
  const MentorSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => MentorProfileBloc(
            repository: context.read<ProfileRepository>(),
          )..add(LoadMentorProfile(userId)),
        ),
        BlocProvider.value(value: context.read<ProfileBloc>()),
        BlocProvider.value(value: context.read<VerificationBloc>()),
      ],
      child: const _MentorSetupForm(),
    );
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
  final _industriesController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _expertiseController.dispose();
    _yoeController.dispose();
    _industriesController.dispose();
    _linkedinController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mentor Profile Setup'),
        centerTitle: true,
      ),
      body: BlocConsumer<MentorProfileBloc, MentorProfileState>(
        listener: (context, state) {
          if (state is MentorProfileLoaded) {
            _expertiseController.text = state.profile.expertiseDomains.join(', ');
            _yoeController.text = state.profile.yearsOfExperience?.toString() ?? '';
            _linkedinController.text = state.profile.linkedinUrl ?? '';
            _industriesController.text = state.profile.mentorshipFocus ?? '';
          }
        },
        builder: (context, state) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, pState) {
              if (pState is ProfileLoaded) {
                _nameController.text = pState.profile.fullName ?? '';
                _bioController.text = pState.profile.about ?? '';
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share your expertise to get verified as a mentor.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField('Full Name', _nameController, Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Areas of Expertise',
                        _expertiseController,
                        Icons.psychology_outlined,
                        hint: 'e.g. Marketing, Sales, Tech Architecture',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Years of Experience',
                        _yoeController,
                        Icons.history_toggle_off_outlined,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Target Industries',
                        _industriesController,
                        Icons.category_outlined,
                        hint: 'e.g. Fintech, EdTech, E-commerce',
                      ),
                      const SizedBox(height: 20),
                      _buildTextField('LinkedIn URL', _linkedinController, Icons.link),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Bio',
                        _bioController,
                        Icons.description_outlined,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleSubmit(context, pState),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Submit for Verification'),
                        ),
                      ),
                      const SizedBox(height: 24),
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.brandPurple, size: 20),
          ),
          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  void _handleSubmit(BuildContext context, ProfileState pState) {
    if (_formKey.currentState!.validate()) {
      final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;

      if (pState is ProfileLoaded) {
        context.read<ProfileBloc>().add(UpdateProfile(
              pState.profile.copyWith(
                fullName: _nameController.text,
                about: _bioController.text,
              ),
            ));
      }

      // 2. Update Mentor Profile
      final mentorProfile = MentorProfile(
        profileId: userId,
        expertiseDomains: _expertiseController.text.split(',').map((e) => e.trim()).toList(),
        yearsOfExperience: int.tryParse(_yoeController.text),
        linkedinUrl: _linkedinController.text,
        mentorshipFocus: _industriesController.text,
      );
      context.read<MentorProfileBloc>().add(SaveMentorProfile(mentorProfile));

      // 3. Request Verification
      context.read<VerificationBloc>().add(
            RequestVerification(userId, 'mentor', 'profile_verification'),
          );

      // 4. Show confirmation and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your mentor profile is under review. Admin will verify your account soon.'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    }
  }
}
