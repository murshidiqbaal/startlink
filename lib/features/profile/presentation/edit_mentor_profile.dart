// lib/features/profile/presentation/edit_mentor_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_bloc.dart';
// Re-use field helpers from edit_investor_profile (same file or separate import)
// For simplicity the helpers are repeated minimally below.

class EditMentorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditMentorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          MentorProfileBloc(repository: ctx.read<ProfileRepository>())
            ..add(LoadMentorProfile(profileId)),
      child: _EditMentorBody(profileId: profileId),
    );
  }
}

class _EditMentorBody extends StatefulWidget {
  final String profileId;
  const _EditMentorBody({required this.profileId});
  @override
  State<_EditMentorBody> createState() => _EditMentorBodyState();
}

class _EditMentorBodyState extends State<_EditMentorBody> {
  final _formKey = GlobalKey<FormState>();

  final _focusCtrl = TextEditingController();
  final _yoeCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  final _certCtrl = TextEditingController();

  List<String> _expertise = [];
  final _expertiseInputCtrl = TextEditingController();
  List<String> _certifications = [];

  bool _populated = false;

  @override
  void dispose() {
    for (final c in [
      _focusCtrl,
      _yoeCtrl,
      _linkedinCtrl,
      _certCtrl,
      _expertiseInputCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populate(MentorProfileModel m) {
    if (_populated) return;
    _populated = true;
    setState(() {
      _focusCtrl.text = m.mentorshipFocus ?? '';
      _yoeCtrl.text = m.yearsOfExperience?.toString() ?? '';
      _linkedinCtrl.text = m.linkedinUrl ?? '';
      _expertise = List.from(m.expertiseDomains);
      _certifications = List.from(m.certifications);
    });
  }

  void _addExpertise() {
    for (final raw in _expertiseInputCtrl.text.split(',')) {
      final s = raw.trim();
      if (s.isNotEmpty && !_expertise.contains(s) && _expertise.length < 15) {
        _expertise.add(s);
      }
    }
    _expertiseInputCtrl.clear();
    setState(() {});
  }

  int _calcCompletion() {
    int s = 0;
    if (_expertise.isNotEmpty) s += 30;
    if (_yoeCtrl.text.isNotEmpty) s += 20;
    if (_focusCtrl.text.trim().isNotEmpty) s += 30;
    if (_linkedinCtrl.text.trim().isNotEmpty) s += 20;
    return s;
  }

  void _save(MentorProfile existing) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = MentorProfileModel(
      profileId: existing.profileId,
      expertiseDomains: _expertise,
      yearsOfExperience: int.tryParse(_yoeCtrl.text),
      mentorshipFocus: _noe(_focusCtrl.text),
      linkedinUrl: _noe(_linkedinCtrl.text),
      certifications: _certifications,
      profileCompletion: _calcCompletion(),
      isVerified: existing.isVerified,
    );
    context.read<MentorProfileBloc>().add(
      SaveMentorProfile(updated as MentorProfile),
    );
  }

  String? _noe(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MentorProfileBloc, MentorProfileState>(
      listener: (ctx, state) {
        if (state is MentorProfileLoaded && !_populated)
          _populate(state.profile! as MentorProfileModel);
        if (state is MentorProfileSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Mentor profile saved ✓'),
              backgroundColor: AppColors.emerald,
            ),
          );
          Navigator.pop(ctx, true);
        }
        if (state is MentorProfileError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final isLoading = state is MentorProfileLoading;
        final isSaving = state is MentorProfileSaving;
        final existing = state is MentorProfileLoaded
            ? state.profile
            : MentorProfileModel(profileId: widget.profileId);

        if (isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _editAppBar(
            ctx,
            'Edit Mentor Profile',
            isSaving,
            () => _save(existing),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                _MentorCompletionBar(pct: _calcCompletion()),
                const SizedBox(height: 24),

                _MentorSectionLabel('Expertise Domains'),
                const SizedBox(height: 12),
                _ChipTagInput(
                  label: 'Add domains (comma separated)',
                  icon: Icons.psychology_outlined,
                  controller: _expertiseInputCtrl,
                  tags: _expertise,
                  onAdd: _addExpertise,
                  onRemove: (s) => setState(() => _expertise.remove(s)),
                ),

                const SizedBox(height: 20),
                _MentorSectionLabel('Experience & Focus'),
                const SizedBox(height: 12),
                _MentorTF(
                  'Years of Experience *',
                  Icons.work_outline,
                  _yoeCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                _MentorTF(
                  'Mentorship Focus *',
                  Icons.lightbulb_outline,
                  _focusCtrl,
                  hint: 'Startups, Career growth, Tech leadership',
                  maxLines: 3,
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),

                const SizedBox(height: 20),
                _MentorSectionLabel('Links'),
                const SizedBox(height: 12),
                _MentorTF(
                  'LinkedIn URL *',
                  Icons.link,
                  _linkedinCtrl,
                  hint: 'https://linkedin.com/in/…',
                  keyboardType: TextInputType.url,
                  validator: (v) =>
                      v?.trim().isEmpty == true ? 'Required' : null,
                ),

                const SizedBox(height: 20),
                _MentorSectionLabel('Certifications (optional)'),
                const SizedBox(height: 12),
                _ChipTagInput(
                  label: 'Add certifications',
                  icon: Icons.verified_outlined,
                  controller: _certCtrl,
                  tags: _certifications,
                  onAdd: () {
                    final s = _certCtrl.text.trim();
                    if (s.isNotEmpty) {
                      setState(() {
                        _certifications.add(s);
                        _certCtrl.clear();
                      });
                    }
                  },
                  onRemove: (s) => setState(() => _certifications.remove(s)),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  height: 54,
                  child: isSaving
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brandPurple,
                          ),
                        )
                      : _MentorGradientBtn(
                          label: 'Save Profile',
                          onPressed: () => _save(existing),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS (mentor + collaborator screens)
// ─────────────────────────────────────────────────────────────────────────────

PreferredSizeWidget _editAppBar(
  BuildContext context,
  String title,
  bool saving,
  VoidCallback onSave,
) {
  return AppBar(
    backgroundColor: AppColors.background,
    elevation: 0,
    title: Text(
      title,
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
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: saving
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.brandPurple,
                ),
              )
            : TextButton(
                onPressed: onSave,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      ),
    ],
  );
}

class _MentorCompletionBar extends StatelessWidget {
  final int pct;
  const _MentorCompletionBar({required this.pct});

  Color get _c {
    if (pct < 40) return AppColors.rose;
    if (pct < 70) return AppColors.amber;
    return AppColors.emerald;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceGlass,
        border: Border.all(color: _c.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Profile Strength',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _c,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation<Color>(_c),
            ),
          ),
        ],
      ),
    );
  }
}

class _MentorSectionLabel extends StatelessWidget {
  final String text;
  const _MentorSectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      color: AppColors.brandPurple,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );
}

class _MentorTF extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController ctrl;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _MentorTF(
    this.label,
    this.icon,
    this.ctrl, {
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    validator: validator,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.rose),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}


class _ChipTagInput extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  const _ChipTagInput({
    required this.label,
    required this.icon,
    required this.controller,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MentorTF(
                label,
                icon,
                controller,
                hint: 'Flutter, AI — comma separated',
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [AppColors.brandPurple, AppColors.brandCyan],
                  ),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tags
                .map(
                  (s) => Chip(
                    backgroundColor: AppColors.brandPurple.withValues(
                      alpha: 0.14,
                    ),
                    side: BorderSide(
                      color: AppColors.brandPurple.withValues(alpha: 0.4),
                    ),
                    label: Text(
                      s,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    onDeleted: () => onRemove(s),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _MentorGradientBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _MentorGradientBtn({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [AppColors.brandPurple, AppColors.brandCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    ),
  );
}
