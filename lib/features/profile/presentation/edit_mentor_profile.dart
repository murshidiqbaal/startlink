// lib/features/profile/presentation/edit_mentor_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/mentor_edit_controller.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_screen_template.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_shared_widgets.dart';

class EditMentorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditMentorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoleProfileBloc(
        repository: context.read<ProfileRepository>(),
      )..add(LoadRoleProfile(profileId: profileId, role: 'mentor')),
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
    return ProfileEditScreenTemplate(
      title: 'Edit Mentor Profile',
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

            const ProfileSectionHeader('Expertise Domains'),
            ProfileTagInput(
              label: 'Add domains (comma separated)',
              icon: Icons.psychology_outlined,
              controller: _controller.expertiseInputCtrl,
              tags: _controller.expertise,
              onAdd: _addExpertise,
              onRemove: (s) => setState(() => _controller.expertise.remove(s)),
            ),

            const ProfileSectionHeader('Experience & Focus'),
            ProfileTextField(
              label: 'Years of Experience *',
              icon: Icons.work_outline,
              controller: _controller.yoeCtrl,
              keyboardType: TextInputType.number,
              validator: _req,
            ),
            const SizedBox(height: 12),
            ProfileTextField(
              label: 'Mentorship Focus *',
              icon: Icons.lightbulb_outline,
              controller: _controller.focusCtrl,
              hint: 'Startups, Career growth, Tech leadership',
              maxLines: 3,
              validator: _req,
            ),

            const ProfileSectionHeader('Links'),
            ProfileTextField(
              label: 'LinkedIn URL *',
              icon: Icons.link,
              controller: _controller.linkedinCtrl,
              hint: 'https://linkedin.com/in/…',
              keyboardType: TextInputType.url,
              validator: _req,
            ),

            const ProfileSectionHeader('Certifications (optional)'),
            ProfileTagInput(
              label: 'Add certifications',
              icon: Icons.verified_outlined,
              controller: _controller.certCtrl,
              tags: _controller.certifications,
              onAdd: () {
                final s = _controller.certCtrl.text.trim();
                if (s.isNotEmpty) {
                  setState(() {
                    _controller.certifications.add(s);
                    _controller.certCtrl.clear();
                  });
                }
              },
              onRemove: (s) => setState(() => _controller.certifications.remove(s)),
            ),
          ],
        );
      },
    );
  }

  String? _req(String? v) => v?.trim().isEmpty == true ? 'Required' : null;
}
