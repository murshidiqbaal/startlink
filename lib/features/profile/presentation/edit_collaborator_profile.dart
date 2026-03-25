// lib/features/profile/presentation/edit_collaborator_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/collaborator_edit_controller.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_screen_template.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_shared_widgets.dart';

class EditCollaboratorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditCollaboratorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleProfileBloc(
        repository: context.read<ProfileRepository>(),
      )..add(LoadRoleProfile(profileId: profileId, role: 'collaborator')),
      child: _EditCollaboratorForm(profileId: profileId),
    );
  }
}

class _EditCollaboratorForm extends StatefulWidget {
  final String profileId;
  const _EditCollaboratorForm({required this.profileId});

  @override
  State<_EditCollaboratorForm> createState() => _EditCollaboratorFormState();
}

class _EditCollaboratorFormState extends State<_EditCollaboratorForm> {
  final _controller = CollaboratorEditController();

  void _addTag(TextEditingController ctrl, List<String> list) {
    final s = ctrl.text.trim();
    if (s.isNotEmpty && !list.contains(s)) {
      setState(() {
        list.add(s);
        ctrl.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditScreenTemplate(
      title: 'Edit Collaborator Profile',
      profileId: widget.profileId,
      controller: _controller,
      buildForm: (context, state) {
        return Column(
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

            const ProfileSectionHeader('Expertise'),
            ProfileTagInput(
              label: 'Specialties',
              icon: Icons.star_outline,
              controller: _controller.specInputCtrl,
              tags: _controller.specialties,
              onAdd: () => _addTag(_controller.specInputCtrl, _controller.specialties),
              onRemove: (s) => setState(() => _controller.specialties.remove(s)),
            ),
            const SizedBox(height: 12),
            ProfileTagInput(
              label: 'Preferred Project Types',
              icon: Icons.folder_open,
              controller: _controller.projTypeInputCtrl,
              tags: _controller.preferredProjectTypes,
              onAdd: () =>
                  _addTag(_controller.projTypeInputCtrl, _controller.preferredProjectTypes),
              onRemove: (s) =>
                  setState(() => _controller.preferredProjectTypes.remove(s)),
            ),

            const ProfileSectionHeader('Experience & Rate'),
            ProfileTextField(
              label: 'Years of Experience *',
              icon: Icons.work_outline,
              controller: _controller.yoeCtrl,
              keyboardType: TextInputType.number,
              validator: _req,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Hourly Rate (\$)',
              icon: Icons.monetization_on_outlined,
              controller: _controller.hourlyRateCtrl,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _dropdown(
              'Availability',
              Icons.event_available,
              _controller.availability,
              ['Full-time', 'Part-time', 'Freelance', 'Contract'],
              (v) => setState(() => _controller.availability = v),
            ),

            const ProfileSectionHeader('Professional Links'),
            ProfileTextField(
              label: 'LinkedIn URL',
              icon: Icons.link,
              controller: _controller.linkedinUrlCtrl,
              hint: 'https://linkedin.com/in/…',
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'GitHub URL',
              icon: Icons.code,
              controller: _controller.githubUrlCtrl,
              hint: 'https://github.com/…',
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Portfolio URL',
              icon: Icons.language,
              controller: _controller.portfolioUrlCtrl,
              hint: 'https://…',
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Resume URL',
              icon: Icons.article_outlined,
              controller: _controller.resumeUrlCtrl,
              hint: 'Drive/Dropbox link…',
            ),

            const ProfileSectionHeader('Collaborator Bio'),
            ProfileTextField(
              label: 'Detailed Bio',
              icon: Icons.notes,
              controller: _controller.bioCtrl,
              hint: 'Tell us more about your background…',
              maxLines: 4,
            ),
          ],
        );
      },
    );
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
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
          borderSide: const BorderSide(color: AppColors.brandPurple, width: 1.5),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select…', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }
}
