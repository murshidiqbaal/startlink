// lib/features/profile/presentation/edit_innovator_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/innovator_edit_controller.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_screen_template.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_shared_widgets.dart';

class EditInnovatorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditInnovatorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleProfileBloc(
        repository: context.read<ProfileRepository>(),
      )..add(LoadRoleProfile(profileId: profileId, role: 'innovator')),
      child: _EditInnovatorForm(profileId: profileId),
    );
  }
}

class _EditInnovatorForm extends StatefulWidget {
  final String profileId;
  const _EditInnovatorForm({required this.profileId});

  @override
  State<_EditInnovatorForm> createState() => _EditInnovatorFormState();
}

class _EditInnovatorFormState extends State<_EditInnovatorForm> {
  final _controller = InnovatorEditController();

  void _addSkill() {
    final raw = _controller.skillInputCtrl.text;
    for (final s in raw.split(',')) {
      final trimmed = s.trim();
      if (trimmed.isNotEmpty && !_controller.skills.contains(trimmed)) {
        setState(() => _controller.skills.add(trimmed));
      }
    }
    _controller.skillInputCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileEditScreenTemplate(
      title: 'Edit Innovator Profile',
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

            const ProfileSectionHeader('Skills'),
            ProfileTagInput(
              label: 'Add skills (comma separated)',
              icon: Icons.terminal_outlined,
              controller: _controller.skillInputCtrl,
              tags: _controller.skills,
              onAdd: _addSkill,
              onRemove: (s) => setState(() => _controller.skills.remove(s)),
            ),

            const ProfileSectionHeader('Background'),
            _dropdown(
              'Experience Level',
              Icons.trending_up,
              _controller.experienceLevel,
              ['Student', 'Junior', 'Mid-level', 'Senior', 'Founder'],
              (v) => setState(() => _controller.experienceLevel = v),
            ),
            const SizedBox(height: 12),
            _dropdown(
              'Current Status',
              Icons.work_outline,
              _controller.currentStatus,
              ['Looking for co-founder', 'Building a startup', 'Employed', 'Student'],
              (v) => setState(() => _controller.currentStatus = v),
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Education',
              icon: Icons.school_outlined,
              controller: _controller.educationCtrl,
              hint: 'University or Degree…',
            ),

            const ProfileSectionHeader('Startup Details'),
            SwitchListTile(
              title: const Text('Are you building a startup?', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _controller.buildingStartup,
              activeColor: AppColors.brandPurple,
              onChanged: (v) => setState(() => _controller.buildingStartup = v),
            ),
            if (_controller.buildingStartup) ...[
              const SizedBox(height: 8),
              ProfileTextField(
                label: 'Startup Name',
                icon: Icons.rocket_launch_outlined,
                controller: _controller.startupNameCtrl,
              ),
            ],

            const ProfileSectionHeader('Goals'),
            CheckboxListTile(
              title: const Text('Open to Co-founders', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _controller.openToCofounder,
              activeColor: AppColors.brandPurple,
              onChanged: (v) => setState(() => _controller.openToCofounder = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Open to Investors', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _controller.openToInvestors,
              activeColor: AppColors.brandPurple,
              onChanged: (v) => setState(() => _controller.openToInvestors = v ?? false),
            ),
            CheckboxListTile(
              title: const Text('Open to Mentors', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: _controller.openToMentors,
              activeColor: AppColors.brandPurple,
              onChanged: (v) => setState(() => _controller.openToMentors = v ?? false),
            ),

            const ProfileSectionHeader('Professional Links'),
            ProfileTextField(
              label: 'LinkedIn URL',
              icon: Icons.link,
              controller: _controller.linkedinUrlCtrl,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'GitHub URL',
              icon: Icons.code,
              controller: _controller.githubUrlCtrl,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Portfolio URL',
              icon: Icons.language,
              controller: _controller.portfolioUrlCtrl,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Twitter URL',
              icon: Icons.alternate_email,
              controller: _controller.twitterUrlCtrl,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Resume URL',
              icon: Icons.article_outlined,
              controller: _controller.resumeUrlCtrl,
            ),

            const ProfileSectionHeader('Work Preference'),
            _dropdown(
              'Preferred Work Mode',
              Icons.home_work_outlined,
              _controller.preferredWorkMode,
              ['Remote', 'On-site', 'Hybrid'],
              (v) => setState(() => _controller.preferredWorkMode = v),
            ),

            const ProfileSectionHeader('Innovator Bio'),
            ProfileTextField(
              label: 'Innovator Bio',
              icon: Icons.notes,
              controller: _controller.bioCtrl,
              hint: 'Tell us about your journey…',
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
