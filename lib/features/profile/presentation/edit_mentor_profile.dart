// lib/features/profile/presentation/edit_mentor_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_state.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/mentor_edit_controller.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_shared_widgets.dart';
import 'package:startlink/features/profile/presentation/widgets/verification_status_card.dart';

class EditMentorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditMentorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<MentorProfileBloc>()
        ..add(LoadMentorProfile(profileId)),
      child: _EditMentorForm(profileId: profileId),
    );
  }
}

class _EditMentorForm extends StatefulWidget {
  final String profileId;
  const _EditMentorForm({required this.profileId});

  @override
  State<_EditMentorForm> createState() => _EditMentorFormState();
}

class _EditMentorFormState extends State<_EditMentorForm> {
  final _controller = MentorEditController();
  final _formKey = GlobalKey<FormState>();

  void _addExpertise() {
    final raw = _controller.expertiseInputCtrl.text;
    for (final s in raw.split(',')) {
      final trimmed = s.trim();
      if (trimmed.isNotEmpty && !_controller.expertise.contains(trimmed)) {
        setState(() => _controller.expertise.add(trimmed));
      }
    }
    _controller.expertiseInputCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MentorProfileBloc, MentorProfileState>(
      listener: (context, state) {
        if (state is MentorProfileLoaded) {
          _controller.populate(state.baseProfile, state.profile);
        }
        if (state is MentorProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mentor profile saved ✓'),
              backgroundColor: AppColors.emerald,
            ),
          );
        }
        if (state is MentorProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      },
      builder: (context, state) {
        final isSaving = state is MentorProfileSaving;
        final isLoading =
            state is MentorProfileLoading || state is MentorProfileInitial;

        if (isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            ),
          );
        }

        MentorProfileLoaded? loaded;
        if (state is MentorProfileLoaded) {
          loaded = state;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              'Edit Mentor Profile',
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
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                if (loaded != null) ...[
                  ProfileCompletionBar(
                    pct: loaded.profile.profileCompletion,
                  ),
                  const SizedBox(height: 20),
                  VerificationStatusCard(
                    status: _mapStatus(loaded.verification?.status),
                    role: 'mentor',
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

                    const ProfileSectionHeader('Mentor Profile'),
                    ProfileTextField(
                      label: 'Bio / Mentorship Philosophy *',
                      icon: Icons.psychology_outlined,
                      controller: _controller.bioCtrl,
                      hint: 'Describe your expertise and how you can help...',
                      maxLines: 4,
                      validator: _req,
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      label: 'Years of Experience *',
                      icon: Icons.timer_outlined,
                      controller: _controller.yoeCtrl,
                      keyboardType: TextInputType.number,
                      validator: _req,
                    ),

                    const ProfileSectionHeader('Expertise'),
                    ProfileTagInput(
                      label: 'Topics (e.g. Scaling, Fundraising)',
                      icon: Icons.star_outline,
                      controller: _controller.expertiseInputCtrl,
                      tags: _controller.expertise,
                      onAdd: _addExpertise,
                      onRemove: (s) => setState(() => _controller.expertise.remove(s)),
                    ),

                    const ProfileSectionHeader('Availability & Links'),
                    ProfileTextField(
                      label: 'Availability',
                      icon: Icons.calendar_today_outlined,
                      controller: _controller.availabilityCtrl,
                      hint: 'e.g. Tuedays 5pm-7pm, 2 hrs/week',
                    ),
                    const SizedBox(height: 12),
                    ProfileTextField(
                      label: 'LinkedIn URL *',
                      icon: Icons.link,
                      controller: _controller.linkedinCtrl,
                      hint: 'https://linkedin.com/in/…',
                      keyboardType: TextInputType.url,
                      validator: _req,
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
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    final updatedBase = _controller.buildBaseProfile(baseProfile);
    final updatedMentor = _controller.buildRoleProfile(widget.profileId);

    context.read<MentorProfileBloc>().add(
      UpdateConsolidatedProfile(
        baseProfile: updatedBase,
        mentorProfile: updatedMentor,
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
}
