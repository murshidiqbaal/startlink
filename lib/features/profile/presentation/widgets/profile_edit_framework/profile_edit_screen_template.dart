// lib/features/profile/presentation/widgets/profile_edit_framework/profile_edit_screen_template.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_shared_widgets.dart';
import 'package:startlink/features/profile/presentation/widgets/verification_status_card.dart';

class ProfileEditScreenTemplate extends StatefulWidget {
  final String title;
  final String profileId;
  final ProfileEditController controller;
  final Widget Function(BuildContext, RoleProfileState) buildForm;
  final void Function(BuildContext, RoleProfile roleProfile)? onSave;

  const ProfileEditScreenTemplate({
    super.key,
    required this.title,
    required this.profileId,
    required this.controller,
    required this.buildForm,
    this.onSave,
  });

  @override
  State<ProfileEditScreenTemplate> createState() => _ProfileEditScreenTemplateState();
}

class _ProfileEditScreenTemplateState extends State<ProfileEditScreenTemplate> {
  final _formKey = GlobalKey<FormState>();
  bool _populated = false;

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  void _save(RoleProfile roleProfile, ProfileModel baseProfile) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final updatedBase = widget.controller.buildBaseProfile(baseProfile);
    final updatedRole = widget.controller.buildRoleProfile(widget.profileId);

    context.read<RoleProfileBloc>().add(
          SaveRoleProfile(
            baseProfile: updatedBase,
            roleProfile: updatedRole,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoleProfileBloc, RoleProfileState>(
      listener: (context, state) {
        if (state.baseProfile != null && state.profile != null && !_populated) {
          _populated = true;
          widget.controller.populate(state.baseProfile!, state.profile!);
        }
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.title} saved ✓'),
              backgroundColor: AppColors.emerald,
            ),
          );
        }
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading && state.baseProfile == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            ),
          );
        }

        final baseProfile = state.baseProfile;
        final roleProfile = state.profile;

        if (baseProfile == null || roleProfile == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('Error loading profile', style: TextStyle(color: Colors.white))),
          );
        }

        final isSaving = state.isSaving;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              widget.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.brandPurple,
                      ),
                    ),
                  ),
                )
              else
                TextButton(
                  onPressed: () => _save(roleProfile, baseProfile),
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
                ProfileCompletionBar(pct: state.completionScore),
                const SizedBox(height: 20),
                VerificationStatusCard(
                  status: state.verificationStatus,
                  role: widget.title.toLowerCase().contains('investor') ? 'investor' : 'mentor',
                ),
                widget.buildForm(context, state),
                const SizedBox(height: 40),
                ProfileSaveButton(
                  label: 'Save Profile',
                  isLoading: isSaving,
                  onPressed: () => _save(roleProfile, baseProfile),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
