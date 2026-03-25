import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_event.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';

class InvestorSetupScreen extends StatelessWidget {
  const InvestorSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthBloc>().state is AuthAuthenticated
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => InvestorProfileBloc(
            repository: context.read<ProfileRepository>(),
          )..add(LoadInvestorProfile(userId)),
        ),
        BlocProvider.value(value: context.read<ProfileBloc>()),
        BlocProvider.value(value: context.read<VerificationBloc>()),
      ],
      child: const _InvestorSetupForm(),
    );
  }
}

class _InvestorSetupForm extends StatefulWidget {
  const _InvestorSetupForm();

  @override
  State<_InvestorSetupForm> createState() => _InvestorSetupFormState();
}

class _InvestorSetupFormState extends State<_InvestorSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _minTicketController = TextEditingController();
  final _maxTicketController = TextEditingController();
  final _interestsController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _minTicketController.dispose();
    _maxTicketController.dispose();
    _interestsController.dispose();
    _linkedinController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Investor Profile Setup'),
        centerTitle: true,
      ),
      body: BlocConsumer<InvestorProfileBloc, InvestorProfileState>(
        listener: (context, state) {
          if (state is InvestorProfileLoaded) {
            _interestsController.text = state.profile.investmentFocus ?? '';
            _minTicketController.text = state.profile.ticketSizeMin?.toString() ?? '';
            _maxTicketController.text = state.profile.ticketSizeMax?.toString() ?? '';
            _companyController.text = state.profile.organizationName ?? '';
            _linkedinController.text = state.profile.linkedinUrl ?? '';
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
                        'Complete your profile to get verified.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildTextField('Full Name', _nameController, Icons.person_outline),
                      const SizedBox(height: 20),
                      _buildTextField('Company / Organization', _companyController, Icons.business_outlined),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              'Min Ticket (\$)',
                              _minTicketController,
                              Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              'Max Ticket (\$)',
                              _maxTicketController,
                              Icons.attach_money,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        'Industry Interests',
                        _interestsController,
                        Icons.category_outlined,
                        hint: 'e.g. SaaS, AI, HealthTech',
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

      // 2. Update Investor Profile
      final investorProfile = InvestorProfile(
        profileId: userId,
        investmentFocus: _interestsController.text,
        ticketSizeMin: double.tryParse(_minTicketController.text),
        ticketSizeMax: double.tryParse(_maxTicketController.text),
        organizationName: _companyController.text,
        linkedinUrl: _linkedinController.text,
      );
      context.read<InvestorProfileBloc>().add(SaveInvestorProfile(investorProfile));

      // 3. Request Verification
      context.read<VerificationBloc>().add(
            RequestVerification(userId, 'investor', 'profile_verification'),
          );

      // 4. Show confirmation and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your investor profile is under review. Admin will verify your account soon.'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context);
    }
  }
}
