// lib/features/profile/presentation/edit_investor_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_state.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/investor_edit_controller.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_completion_service.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_shared_widgets.dart';
import 'package:startlink/features/profile/presentation/widgets/verification_status_card.dart';

class EditInvestorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditInvestorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<InvestorProfileBloc>()
        ..add(LoadInvestorProfile(profileId)),
      child: _EditInvestorForm(profileId: profileId),
    );
  }
}

class _EditInvestorForm extends StatefulWidget {
  final String profileId;
  const _EditInvestorForm({required this.profileId});

  @override
  State<_EditInvestorForm> createState() => _EditInvestorFormState();
}

class _EditInvestorFormState extends State<_EditInvestorForm> {
  final _controller = InvestorEditController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestorProfileBloc, InvestorProfileState>(
      listener: (context, state) {
        if (state is InvestorProfileLoaded) {
          _controller.populate(state.baseProfile, state.profile);
        }
        if (state is InvestorProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Investor profile saved ✓'),
              backgroundColor: AppColors.emerald,
            ),
          );
        }
        if (state is InvestorProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is InvestorProfileSaving;
        final isLoading =
            state is InvestorProfileLoading || state is InvestorProfileInitial;

        if (isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            ),
          );
        }

        InvestorProfileLoaded? loaded;
        if (state is InvestorProfileLoaded) {
          loaded = state;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              'Edit Investor Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isSaving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    if (loaded != null) _save(context, loaded.baseProfile);
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.brandPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: Form(
            key: GlobalKey<FormState>(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                if (loaded != null) ...[
                  ProfileCompletionBar(
                    pct: ProfileCompletionService.calculate(loaded.profile),
                  ),
                  const SizedBox(height: 20),
                  VerificationStatusCard(
                    status: _mapStatus(loaded.verification?.status),
                    role: 'investor',
                  ),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ProfileSectionHeader('Personal Information'),
                    ProfileTextField(
                      label: 'Full Name *',
                      icon: Icons.person_outline,
                      controller: _controller.nameCtrl,
                      validator: _req,
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      label: 'Bio / About',
                      icon: Icons.description_outlined,
                      controller: _controller.aboutCtrl,
                      hint: 'A short intro about yourself…',
                      maxLines: 3,
                    ),

                    const ProfileSectionHeader('Organization'),
                    ProfileTextField(
                      label: 'Organization Name *',
                      icon: Icons.business,
                      controller: _controller.orgCtrl,
                      validator: _req,
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      label: 'LinkedIn URL',
                      icon: Icons.link,
                      controller: _controller.linkedinCtrl,
                      hint: 'https://linkedin.com/in/…',
                      keyboardType: TextInputType.url,
                    ),

                    const ProfileSectionHeader('About Organization'),
                    ProfileTextField(
                      label: 'Strategy / Philosophy',
                      icon: Icons.description,
                      controller: _controller.bioCtrl,
                      hint: 'Tell innovators about your strategy…',
                      maxLines: 4,
                    ),

                    const ProfileSectionHeader('Investment Focus'),
                    ProfileTextField(
                      label: 'Investment Focus *',
                      icon: Icons.track_changes,
                      controller: _controller.focusCtrl,
                      hint: 'SaaS, Fintech, Health',
                      validator: _req,
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      'Preferred Stage',
                      Icons.layers,
                      _controller.stage,
                      ['Pre-Seed', 'Seed', 'Series A', 'Series B', 'Growth'],
                      (v) => setState(() => _controller.stage = v),
                    ),

                    const ProfileSectionHeader('Ticket Size'),
                    Row(
                      children: [
                        Expanded(
                          child: ProfileTextField(
                            label: 'Min (\$)',
                            icon: Icons.attach_money,
                            controller: _controller.minTicketCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ProfileTextField(
                            label: 'Max (\$)',
                            icon: Icons.attach_money,
                            controller: _controller.maxTicketCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                ProfileSaveButton(
                  label: 'Save Profile',
                  isLoading: isSaving,
                  onPressed: () {
                    if (loaded != null) _save(context, loaded.baseProfile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext context, ProfileModel baseProfile) {
    final updatedBase = _controller.buildBaseProfile(baseProfile);
    final updatedInvestor = _controller.buildRoleProfile(widget.profileId);

    context.read<InvestorProfileBloc>().add(
      UpdateConsolidatedProfile(
        baseProfile: updatedBase,
        investorProfile: updatedInvestor,
      ),
    );
  }

  VerificationStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notVerified;
    }
  }

  String? _req(String? v) => v?.trim().isEmpty == true ? 'Required' : null;

  Widget _dropdown(
    String label,
    IconData icon,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF1A1A22),
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.25),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.brandPurple,
            width: 1.5,
          ),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'Select…',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }
}
