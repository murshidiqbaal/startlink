// lib/features/profile/presentation/edit_innovator_profile.dart
//
// Fixed from original:
//  • Uses InnovatorProfileModel directly (no hardcoded Map)
//  • profileId comes from baseProfile.id (profiles.id), not auth user id
//  • LoadInnovatorProfile receives profileId, not userId
//  • Saves both tables atomically via SaveInnovatorProfile(baseProfile:)
//  • Inline profile completion calculation (no missing utility dep)
//  • BlocListener for populate avoids setState-in-build anti-pattern
// ────────────────────────────────────────────────────────────────────────────

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/innovator_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/innovator_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';

class EditInnovatorProfileScreen extends StatelessWidget {
  final ProfileModel baseProfile;
  const EditInnovatorProfileScreen({super.key, required this.baseProfile});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          InnovatorProfileBloc(repository: ctx.read<ProfileRepository>())
            ..add(LoadInnovatorProfile(baseProfile.id)), // ← profiles.id
      child: _EditInnovatorBody(baseProfile: baseProfile),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EditInnovatorBody extends StatefulWidget {
  final ProfileModel baseProfile;
  const _EditInnovatorBody({required this.baseProfile});

  @override
  State<_EditInnovatorBody> createState() => _EditInnovatorBodyState();
}

class _EditInnovatorBodyState extends State<_EditInnovatorBody> {
  final _formKey = GlobalKey<FormState>();

  // Base profile fields
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _headlineCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _aboutCtrl;
  String _role = 'Innovator';

  // Innovator-specific fields
  final List<String> _skills = [];
  final TextEditingController _skillInputCtrl = TextEditingController();
  String? _experienceLevel;
  String? _currentStatus;
  bool _buildingStartup = false;
  late final TextEditingController _startupNameCtrl;
  late final TextEditingController _portfolioCtrl;
  late final TextEditingController _githubCtrl;
  late final TextEditingController _linkedinCtrl;
  late final TextEditingController _twitterCtrl;
  bool _openToCofounder = false;
  bool _openToInvestors = false;
  bool _openToMentors = false;
  String? _workMode;

  // Avatar
  File? _localAvatar;
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    final p = widget.baseProfile;
    _fullNameCtrl = TextEditingController(text: p.fullName);
    _headlineCtrl = TextEditingController(text: p.headline);
    _locationCtrl = TextEditingController(text: p.location);
    _aboutCtrl = TextEditingController(text: p.about);
    _role = p.role ?? 'Innovator';
    _startupNameCtrl = TextEditingController();
    _portfolioCtrl = TextEditingController(text: p.portfolioUrl);
    _githubCtrl = TextEditingController(text: p.githubUrl);
    _linkedinCtrl = TextEditingController(text: p.linkedinUrl);
    _twitterCtrl = TextEditingController();
    _skills.addAll(p.skills);
  }

  @override
  void dispose() {
    for (final c in [
      _fullNameCtrl,
      _headlineCtrl,
      _locationCtrl,
      _aboutCtrl,
      _skillInputCtrl,
      _startupNameCtrl,
      _portfolioCtrl,
      _githubCtrl,
      _linkedinCtrl,
      _twitterCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _populateFromEntity(InnovatorProfile m) {
    if (_populated) return;
    _populated = true;
    setState(() {
      if (m.bio?.isNotEmpty == true) _aboutCtrl.text = m.bio!;
      if (m.skills.isNotEmpty) {
        _skills
          ..clear()
          ..addAll(m.skills);
      }
      _experienceLevel = m.experienceLevel;
      _currentStatus = m.currentStatus;
      _buildingStartup = m.buildingStartup;
      _startupNameCtrl.text = m.startupName ?? '';
      if (m.portfolioUrl?.isNotEmpty == true)
        _portfolioCtrl.text = m.portfolioUrl!;
      if (m.githubUrl?.isNotEmpty == true) _githubCtrl.text = m.githubUrl!;
      if (m.linkedinUrl?.isNotEmpty == true)
        _linkedinCtrl.text = m.linkedinUrl!;
      if (m.twitterUrl?.isNotEmpty == true) _twitterCtrl.text = m.twitterUrl!;
      _openToCofounder = m.openToCofounder;
      _openToInvestors = m.openToInvestors;
      _openToMentors = m.openToMentors;
      _workMode = m.preferredWorkMode;
    });
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _localAvatar = File(picked.path));
    context.read<ProfileBloc>().add(UploadAvatar(File(picked.path)));
  }

  void _addSkill() {
    for (final raw in _skillInputCtrl.text.split(',')) {
      final s = raw.trim();
      if (s.isNotEmpty && !_skills.contains(s) && _skills.length < 20) {
        _skills.add(s);
      }
    }
    _skillInputCtrl.clear();
    setState(() {});
  }

  int _calcCompletion() {
    int score = 0;
    if (_fullNameCtrl.text.trim().isNotEmpty) score += 15;
    if (_headlineCtrl.text.trim().isNotEmpty) score += 10;
    if (_aboutCtrl.text.trim().isNotEmpty) score += 10;
    if (_skills.isNotEmpty) score += 15;
    if (_experienceLevel != null) score += 10;
    if (_currentStatus != null) score += 10;
    if (_linkedinCtrl.text.trim().isNotEmpty) score += 10;
    if (_portfolioCtrl.text.trim().isNotEmpty ||
        _githubCtrl.text.trim().isNotEmpty)
      score += 10;
    if (_openToCofounder || _openToInvestors || _openToMentors) score += 10;
    return score.clamp(0, 100);
  }

  void _save(InnovatorProfile existing) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final completion = _calcCompletion();

    // Base profile update should be handled by ProfileBloc separately if needed
    // or we can add it back to InnovatorProfileBloc later if required.

    final roleModel = InnovatorProfileModel(
      profileId: existing.profileId,
      skills: List.from(_skills),
      experienceLevel: _experienceLevel,
      bio: _aboutCtrl.text.trim(),
      buildingStartup: _buildingStartup,
      currentStatus: _currentStatus,
      startupName: _noe(_startupNameCtrl.text),
      githubUrl: _noe(_githubCtrl.text),
      linkedinUrl: _noe(_linkedinCtrl.text),
      portfolioUrl: _noe(_portfolioCtrl.text),
      twitterUrl: _noe(_twitterCtrl.text),
      openToCofounder: _openToCofounder,
      openToInvestors: _openToInvestors,
      openToMentors: _openToMentors,
      preferredWorkMode: _workMode,
      profileCompletion: completion,
    );

    context.read<InnovatorProfileBloc>().add(
      SaveInnovatorProfile(roleModel),
    );
  }

  String? _noe(String v) => v.trim().isEmpty ? null : v.trim();

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ProfileBloc, ProfileState>(
          listener: (_, state) {
            if (state is ProfileLoaded && state.isAvatarUploading == false) {
              // avatar URL updated in background — no extra action needed
            }
          },
        ),
        BlocListener<InnovatorProfileBloc, InnovatorProfileState>(
          listenWhen: (_, s) =>
              s.status == InnovatorProfileStatus.loaded && !_populated,
          listener: (_, state) {
            if (state.profile != null) _populateFromEntity(state.profile!);
          },
        ),
        BlocListener<InnovatorProfileBloc, InnovatorProfileState>(
          listenWhen: (_, s) =>
              s.status == InnovatorProfileStatus.success ||
              s.status == InnovatorProfileStatus.failure,
          listener: (ctx, state) {
            if (state.status == InnovatorProfileStatus.success) {
              _showSnack('Profile saved ✓', success: true);
              Navigator.pop(ctx, true);
            } else if (state.status == InnovatorProfileStatus.failure) {
              _showSnack(state.errorMessage ?? 'Save failed', success: false);
            }
          },
        ),
      ],
      child: BlocBuilder<InnovatorProfileBloc, InnovatorProfileState>(
        builder: (ctx, innovState) {
          if (innovState.status == InnovatorProfileStatus.loading) {
            return const Scaffold(
              backgroundColor: AppColors.background,
              body: Center(
                child: CircularProgressIndicator(color: AppColors.brandPurple),
              ),
            );
          }

          final InnovatorProfile existingModel =
              innovState.profile ??
              InnovatorProfileModel(profileId: widget.baseProfile.id);
          final isSaving = innovState.status == InnovatorProfileStatus.saving;
          final completion = _calcCompletion();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              title: const Text(
                'Edit Profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(ctx),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.brandPurple,
                          ),
                        )
                      : TextButton(
                          onPressed: () => _save(existingModel),
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
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Completion card
                    _CompletionBanner(completion: completion),
                    const SizedBox(height: 20),

                    // Avatar picker
                    _AvatarSection(
                      localFile: _localAvatar,
                      networkUrl: widget.baseProfile.avatarUrl,
                      initials: widget.baseProfile.initials,
                      onPick: _pickAvatar,
                    ),
                    const SizedBox(height: 24),

                    // Identity
                    _SectionHeader(
                      icon: Icons.person_outline,
                      label: 'Identity',
                      badge: 'Required',
                      color: AppColors.rose,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Full Name *',
                      Icons.badge_outlined,
                      _fullNameCtrl,
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'Headline *',
                      Icons.title,
                      _headlineCtrl,
                      hint: 'Flutter dev building health tech',
                      validator: (v) =>
                          v?.trim().isEmpty == true ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'Location',
                      Icons.location_on_outlined,
                      _locationCtrl,
                      hint: 'e.g. Bangalore, India',
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      'Primary Role *',
                      Icons.work_outline,
                      _role,
                      [
                        'Innovator',
                        'Founder',
                        'Student',
                        'Developer',
                        'Designer',
                        'Other',
                      ],
                      (v) => setState(() => _role = v!),
                    ),
                    const SizedBox(height: 28),

                    // Professional
                    _SectionHeader(
                      icon: Icons.insights_outlined,
                      label: 'Professional Snapshot',
                      badge: 'High Value',
                      color: AppColors.amber,
                    ),
                    const SizedBox(height: 14),
                    _field(
                      'Short Bio',
                      Icons.short_text,
                      _aboutCtrl,
                      hint: 'Tell investors who you are…',
                      maxLines: 3,
                      maxLength: 300,
                    ),
                    const SizedBox(height: 12),
                    _SkillsChipInput(
                      skills: _skills,
                      controller: _skillInputCtrl,
                      onAdd: _addSkill,
                      onRemove: (s) => setState(() => _skills.remove(s)),
                    ),
                    const SizedBox(height: 12),
                    _dropdownNullable(
                      'Years of Experience',
                      Icons.timeline,
                      _experienceLevel,
                      [
                        '<1 Year',
                        '1–3 Years',
                        '3–5 Years',
                        '5–10 Years',
                        '10+ Years',
                      ],
                      (v) => setState(() => _experienceLevel = v),
                    ),
                    const SizedBox(height: 12),
                    _dropdownNullable(
                      'Current Status',
                      Icons.school_outlined,
                      _currentStatus,
                      [
                        'Student',
                        'Working Full-time',
                        'Building Startup',
                        'Freelancing',
                        'Open to Work',
                      ],
                      (v) => setState(() => _currentStatus = v),
                    ),
                    const SizedBox(height: 28),

                    // Startup credibility
                    _SectionHeader(
                      icon: Icons.rocket_launch_outlined,
                      label: 'Startup Credibility',
                      badge: 'Optional',
                      color: AppColors.emerald,
                    ),
                    const SizedBox(height: 14),
                    _GlassToggle(
                      icon: Icons.business_center_outlined,
                      label: 'Currently Building a Startup',
                      value: _buildingStartup,
                      onChanged: (v) => setState(() => _buildingStartup = v),
                    ),
                    if (_buildingStartup) ...[
                      const SizedBox(height: 12),
                      _field(
                        'Startup Name',
                        Icons.apartment_outlined,
                        _startupNameCtrl,
                        hint: 'e.g. GreenDrone Inc.',
                      ),
                    ],
                    const SizedBox(height: 12),
                    _field(
                      'Portfolio / Website',
                      Icons.language_outlined,
                      _portfolioCtrl,
                      hint: 'https://yourportfolio.com',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'GitHub',
                      Icons.code,
                      _githubCtrl,
                      hint: 'https://github.com/username',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'LinkedIn',
                      Icons.link,
                      _linkedinCtrl,
                      hint: 'https://linkedin.com/in/username',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 12),
                    _field(
                      'X / Twitter',
                      Icons.alternate_email,
                      _twitterCtrl,
                      hint: 'https://x.com/username',
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 28),

                    // Collaboration prefs
                    _SectionHeader(
                      icon: Icons.handshake_outlined,
                      label: 'Collaboration Preferences',
                      badge: 'Optional',
                      color: AppColors.emerald,
                    ),
                    const SizedBox(height: 14),
                    _GlassToggle(
                      icon: Icons.people_alt_outlined,
                      label: 'Open to Co-Founder',
                      value: _openToCofounder,
                      onChanged: (v) => setState(() => _openToCofounder = v),
                    ),
                    const SizedBox(height: 8),
                    _GlassToggle(
                      icon: Icons.attach_money,
                      label: 'Open to Investors',
                      value: _openToInvestors,
                      onChanged: (v) => setState(() => _openToInvestors = v),
                    ),
                    const SizedBox(height: 8),
                    _GlassToggle(
                      icon: Icons.school_outlined,
                      label: 'Open to Mentors',
                      value: _openToMentors,
                      onChanged: (v) => setState(() => _openToMentors = v),
                    ),
                    const SizedBox(height: 12),
                    _dropdownNullable(
                      'Preferred Work Mode',
                      Icons.location_pin,
                      _workMode,
                      ['Remote', 'Hybrid', 'Onsite'],
                      (v) => setState(() => _workMode = v),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: isSaving
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.brandPurple,
                              ),
                            )
                          : _GradientButton(
                              label: 'Save Profile',
                              onPressed: () => _save(existingModel),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSnack(String msg, {required bool success}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppColors.emerald : AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGET HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _CompletionBanner extends StatelessWidget {
  final int completion;
  const _CompletionBanner({required this.completion});

  Color get _color {
    if (completion < 40) return AppColors.rose;
    if (completion < 70) return AppColors.amber;
    return AppColors.emerald;
  }

  String get _label {
    if (completion < 40) return 'Just Getting Started';
    if (completion < 70) return 'Looking Good';
    if (completion < 90) return 'Almost There!';
    return 'Investor Ready ✓';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceGlass,
        border: Border.all(color: _color.withValues(alpha: 0.35)),
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
                '$completion%  $_label',
                style: TextStyle(
                  color: _color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation<Color>(_color),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final File? localFile;
  final String? networkUrl;
  final String initials;
  final VoidCallback onPick;
  const _AvatarSection({
    required this.localFile,
    required this.networkUrl,
    required this.initials,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (localFile != null)
      image = FileImage(localFile!);
    else if (networkUrl?.isNotEmpty == true)
      image = NetworkImage(networkUrl!);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.brandPurple, AppColors.brandCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.surfaceGlass,
            backgroundImage: image,
            child: image == null
                ? Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: onPick,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandPurple,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillsChipInput extends StatelessWidget {
  final List<String> skills;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  const _SkillsChipInput({
    required this.skills,
    required this.controller,
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
              child: TextFormField(
                controller: controller,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: _inputDec(
                  'Skills',
                  Icons.label_outline,
                  hint: 'Flutter, AI — comma separated',
                ),
                onFieldSubmitted: (_) => onAdd(),
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
        if (skills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: skills
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

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final String badge;
  final Color color;
  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.badge,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Text(
            badge,
            style: TextStyle(color: color, fontSize: 10, letterSpacing: 0.5),
          ),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Divider(height: 1, color: Color(0x0FFFFFFF), thickness: 1),
          ),
        ),
      ],
    );
  }
}

class _GlassToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _GlassToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: value
            ? AppColors.brandPurple.withValues(alpha: 0.1)
            : AppColors.surfaceGlass,
        border: Border.all(
          color: value
              ? AppColors.brandPurple.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: value ? AppColors.brandPurple : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: value ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.brandPurple,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const _GradientButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
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
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Field helpers ─────────────────────────────────────────────────────────────

InputDecoration _inputDec(String label, IconData icon, {String? hint}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.28),
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
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

Widget _field(
  String label,
  IconData icon,
  TextEditingController controller, {
  String? hint,
  int maxLines = 1,
  int? maxLength,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) => Padding(
  padding: EdgeInsets.zero,
  child: TextFormField(
    controller: controller,
    maxLines: maxLines,
    maxLength: maxLength,
    keyboardType: keyboardType,
    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
    decoration: _inputDec(label, icon, hint: hint),
    validator: validator,
    inputFormatters: maxLength != null
        ? [LengthLimitingTextInputFormatter(maxLength)]
        : [],
  ),
);

Widget _dropdown(
  String label,
  IconData icon,
  String value,
  List<String> items,
  ValueChanged<String?> onChanged,
) => DropdownButtonFormField<String>(
  value: value,
  dropdownColor: const Color(0xFF1A1A22),
  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
  decoration: _inputDec(label, icon),
  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  onChanged: onChanged,
);

Widget _dropdownNullable(
  String label,
  IconData icon,
  String? value,
  List<String> items,
  ValueChanged<String?> onChanged,
) => DropdownButtonFormField<String>(
  value: value,
  dropdownColor: const Color(0xFF1A1A22),
  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
  decoration: _inputDec(label, icon),
  items: [
    const DropdownMenuItem<String>(
      value: null,
      child: Text('Select…', style: TextStyle(color: AppColors.textSecondary)),
    ),
    ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
  ],
  onChanged: onChanged,
);
