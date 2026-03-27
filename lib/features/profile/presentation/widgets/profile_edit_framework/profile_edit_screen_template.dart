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
          UpdateRoleProfile(
            baseProfile: updatedBase,
            roleProfile: updatedRole,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RoleProfileBloc, RoleProfileState>(
      listener: (context, state) {
        if (state is RoleProfileLoaded && !_populated) {
          _populated = true;
          widget.controller.populate(state.baseProfile, state.roleProfile);
        }
        if (state is RoleProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.title} saved ✓'),
              backgroundColor: AppColors.emerald,
            ),
          );
        }
        if (state is RoleProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is RoleProfileLoading || state is RoleProfileInitial) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            ),
          );
        }

        if (state is RoleProfileError && !_populated) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.rose),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.read<RoleProfileBloc>().add(
                            LoadRoleProfile(
                              role: widget.title.toLowerCase().contains('investor')
                                  ? 'investor'
                                  : 'mentor',
                            ),
                          ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        RoleProfileLoaded? loadedState;
        if (state is RoleProfileLoaded) {
          loadedState = state;
        } else if (state is RoleProfileSaving || state is RoleProfileSaved) {
          // If we are saving or just saved, we still want to show the form
          // But technically RoleProfileBloc re-emits Loading/Loaded after Save.
          // In our current BLoC, UpdateRoleProfile emits Saving, then Saved, 
          // then adds LoadRoleProfile which emits Loading then Loaded.
          // To avoid flickering, we should probably check if we have previous data.
          // For now, let's assume it's okay or find the last loaded state.
        }

        if (loadedState == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final baseProfile = loadedState.baseProfile;
        final roleProfile = loadedState.roleProfile;
        final isSaving = state is RoleProfileSaving;

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
                ProfileCompletionBar(pct: loadedState.completionScore),
                const SizedBox(height: 20),
                VerificationStatusCard(
                  status: loadedState.verificationStatus,
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
