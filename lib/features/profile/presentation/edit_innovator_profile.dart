// lib/features/profile/presentation/edit_innovator_profile.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/innovator_edit_controller.dart';

// ─── DESIGN TOKENS ────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF080D14);
  static const surface = Color(0xFF0F1623);
  static const surfaceGlass = Color(0xFF131C2B);
  static const cyan = Color(0xFF06B6D4);
  static const purple = Color(0xFF7C3AED);
  static const amber = Color(0xFFF59E0B);
  static const emerald = Color(0xFF10B981);
  static const rose = Color(0xFFF43F5E);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const border = Color(0x1AFFFFFF);
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
class EditInnovatorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditInnovatorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RoleProfileBloc(repository: context.read<ProfileRepository>())
            ..add(LoadRoleProfile(profileId: profileId, role: 'innovator')),
      child: _EditInnovatorForm(profileId: profileId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM
// ─────────────────────────────────────────────────────────────────────────────
class _EditInnovatorForm extends StatefulWidget {
  final String profileId;
  const _EditInnovatorForm({required this.profileId});

  @override
  State<_EditInnovatorForm> createState() => _EditInnovatorFormState();
}

class _EditInnovatorFormState extends State<_EditInnovatorForm>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = InnovatorEditController();
  final _scrollController = ScrollController();
  late final AnimationController _animController;

  bool _isSaving = false;

  // accordion state — 5 sections
  final Map<int, bool> _expanded = {
    0: true,
    1: false,
    2: false,
    3: false,
    4: false,
  };

  // section metadata
  static const _sections = [
    {'title': 'Personal Info', 'icon': Icons.person_outline, 'color': _C.cyan},
    {
      'title': 'Skills & Background',
      'icon': Icons.psychology_outlined,
      'color': _C.purple,
    },
    {
      'title': 'Startup Details',
      'icon': Icons.rocket_launch_outlined,
      'color': _C.amber,
    },
    {
      'title': 'Collaboration Goals',
      'icon': Icons.handshake_outlined,
      'color': _C.emerald,
    },
    {'title': 'Links & Socials', 'icon': Icons.hub_outlined, 'color': _C.cyan},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final raw = _ctrl.skillInputCtrl.text;
    for (final s in raw.split(',')) {
      final trimmed = s.trim();
      if (trimmed.isNotEmpty && !_ctrl.skills.contains(trimmed)) {
        setState(() => _ctrl.skills.add(trimmed));
      }
    }
    _ctrl.skillInputCtrl.clear();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    // TODO: dispatch save event through your BLoC
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // ambient blobs
          Positioned(
            top: -60,
            right: -40,
            child: _Blob(color: _C.purple.withValues(alpha: 0.09), size: 280),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _Blob(color: _C.cyan.withValues(alpha: 0.07), size: 240),
          ),
          // form
          Form(
            key: _formKey,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildCompletionBanner(),
                      const SizedBox(height: 20),
                      ..._sections.asMap().entries.map(
                        (e) => _buildAccordion(e.key, e.value),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // floating save bar
          _buildSaveBar(),
        ],
      ),
    );
  }

  // ── APP BAR ───────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: _C.bg,
      surfaceTintColor: Colors.transparent,
      pinned: true,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _C.surfaceGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.border),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: _C.textPrimary,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_C.purple, _C.cyan]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.manage_accounts_outlined,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Edit Innovator Profile',
            style: TextStyle(
              color: _C.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: _C.bg.withValues(alpha: 0.8)),
        ),
      ),
    );
  }

  // ── COMPLETION BANNER ─────────────────────────────────────────────────────
  Widget _buildCompletionBanner() {
    final filled = [
      _ctrl.nameCtrl.text.isNotEmpty,
      _ctrl.skills.isNotEmpty,
      _ctrl.buildingStartup,
      _ctrl.openToCofounder || _ctrl.openToInvestors || _ctrl.openToMentors,
      _ctrl.linkedinUrlCtrl.text.isNotEmpty ||
          _ctrl.githubUrlCtrl.text.isNotEmpty,
    ].where((e) => e).length;
    final pct = (filled / 5 * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.purple.withValues(alpha: 0.15),
            _C.cyan.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.purple.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: _C.cyan, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Profile Completion',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: const TextStyle(
                  color: _C.cyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(_C.cyan),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete all sections to attract co-founders, mentors & investors',
            style: TextStyle(color: _C.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── ACCORDION ─────────────────────────────────────────────────────────────
  Widget _buildAccordion(int index, Map<String, dynamic> meta) {
    final open = _expanded[index] ?? false;
    final accent = meta['color'] as Color;
    final title = meta['title'] as String;
    final icon = meta['icon'] as IconData;

    final content = [
      _buildPersonalSection,
      _buildSkillsSection,
      _buildStartupSection,
      _buildGoalsSection,
      _buildLinksSection,
    ][index]();

    return AnimatedBuilder(
      animation: _animController,
      builder: (_, __) {
        final t =
            ((_animController.value - index * 0.12).clamp(0.0, 0.4) / 0.4);
        final v = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - v)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: _C.surfaceGlass,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: open ? accent.withValues(alpha: 0.3) : _C.border,
                ),
              ),
              child: Column(
                children: [
                  // header
                  GestureDetector(
                    onTap: () => setState(() => _expanded[index] = !open),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: accent, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            title,
                            style: const TextStyle(
                              color: _C.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          AnimatedRotation(
                            turns: open ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: open ? accent : _C.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // expandable
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: content,
                    ),
                    crossFadeState: open
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                    sizeCurve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── SECTION: PERSONAL INFO ────────────────────────────────────────────────
  Widget _buildPersonalSection() {
    return Column(
      children: [
        _Field(
          label: 'Full Name',
          icon: Icons.person_outline,
          controller: _ctrl.nameCtrl,
          required: true,
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Headline',
          icon: Icons.title,
          controller: _ctrl.aboutCtrl,
          hint: 'e.g. Founder · Startup Builder · Dreamer',
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Innovator Bio',
          icon: Icons.notes,
          controller: _ctrl.bioCtrl,
          hint: 'Tell us about your journey, vision & drive…',
          maxLines: 4,
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Education',
          icon: Icons.school_outlined,
          controller: _ctrl.educationCtrl,
          hint: 'e.g. B.Tech Computer Science, IIT Bombay',
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Dropdown(
          label: 'Preferred Work Mode',
          icon: Icons.home_work_outlined,
          value: _ctrl.preferredWorkMode,
          items: const ['Remote', 'Hybrid', 'On-site'],
          accent: _C.cyan,
          onChanged: (v) => setState(() => _ctrl.preferredWorkMode = v),
        ),
      ],
    );
  }

  // ── SECTION: SKILLS & BACKGROUND ─────────────────────────────────────────
  Widget _buildSkillsSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Add Skills (comma separated)',
                icon: Icons.terminal_outlined,
                controller: _ctrl.skillInputCtrl,
                hint: 'e.g. Flutter, Product Design',
                accent: _C.purple,
              ),
            ),
            const SizedBox(width: 8),
            _AddBtn(onTap: _addSkill, color: _C.purple),
          ],
        ),
        if (_ctrl.skills.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ctrl.skills
                .map(
                  (s) => _RemovableChip(
                    label: s,
                    color: _C.purple,
                    onRemove: () => setState(() => _ctrl.skills.remove(s)),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        _Dropdown(
          label: 'Experience Level',
          icon: Icons.trending_up,
          value: _ctrl.experienceLevel,
          items: const ['Student', 'Junior', 'Mid-level', 'Senior', 'Founder'],
          accent: _C.purple,
          onChanged: (v) => setState(() => _ctrl.experienceLevel = v),
        ),
        const SizedBox(height: 12),
        _Dropdown(
          label: 'Current Status',
          icon: Icons.work_outline,
          value: _ctrl.currentStatus,
          items: const [
            'Looking for co-founder',
            'Building a startup',
            'Employed',
            'Student',
            'Freelancer',
          ],
          accent: _C.purple,
          onChanged: (v) => setState(() => _ctrl.currentStatus = v),
        ),
      ],
    );
  }

  // ── SECTION: STARTUP DETAILS ──────────────────────────────────────────────
  Widget _buildStartupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Building toggle card
        GestureDetector(
          onTap: () =>
              setState(() => _ctrl.buildingStartup = !_ctrl.buildingStartup),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _C.amber.withValues(
                    alpha: _ctrl.buildingStartup ? 0.18 : 0.06,
                  ),
                  _C.purple.withValues(
                    alpha: _ctrl.buildingStartup ? 0.10 : 0.03,
                  ),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _ctrl.buildingStartup
                    ? _C.amber.withValues(alpha: 0.4)
                    : _C.border,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _C.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rocket_launch_outlined,
                    color: _ctrl.buildingStartup ? _C.amber : _C.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Building a Startup',
                        style: TextStyle(
                          color: _ctrl.buildingStartup
                              ? _C.textPrimary
                              : _C.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _ctrl.buildingStartup
                            ? 'Tap to mark as inactive'
                            : 'Tap to indicate you\'re building',
                        style: const TextStyle(
                          color: _C.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 26,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _ctrl.buildingStartup
                        ? _C.amber
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    alignment: _ctrl.buildingStartup
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // startup name if building
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _Field(
              label: 'Startup Name',
              icon: Icons.business_outlined,
              controller: _ctrl.startupNameCtrl,
              hint: 'e.g. StartLink, MemoCare…',
              accent: _C.amber,
            ),
          ),
          crossFadeState: _ctrl.buildingStartup
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeOutCubic,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'One-Line Pitch',
          icon: Icons.lightbulb_outline,
          controller: _ctrl.bioCtrl,
          hint: 'Describe your startup idea in one sentence…',
          accent: _C.amber,
        ),
      ],
    );
  }

  // ── SECTION: COLLABORATION GOALS ─────────────────────────────────────────
  Widget _buildGoalsSection() {
    return Column(
      children: [
        _GoalToggle(
          label: 'Open to Co-Founders',
          subtitle: 'Looking for a technical or business partner',
          icon: Icons.people_alt_outlined,
          color: _C.purple,
          value: _ctrl.openToCofounder,
          onChanged: (v) => setState(() => _ctrl.openToCofounder = v),
        ),
        const SizedBox(height: 10),
        _GoalToggle(
          label: 'Open to Investors',
          subtitle: 'Seeking seed or angel investment',
          icon: Icons.attach_money,
          color: _C.emerald,
          value: _ctrl.openToInvestors,
          onChanged: (v) => setState(() => _ctrl.openToInvestors = v),
        ),
        const SizedBox(height: 10),
        _GoalToggle(
          label: 'Open to Mentors',
          subtitle: 'Looking for experienced guidance',
          icon: Icons.school_outlined,
          color: _C.cyan,
          value: _ctrl.openToMentors,
          onChanged: (v) => setState(() => _ctrl.openToMentors = v),
        ),
      ],
    );
  }

  // ── SECTION: LINKS ────────────────────────────────────────────────────────
  Widget _buildLinksSection() {
    return Column(
      children: [
        _Field(
          label: 'LinkedIn URL',
          icon: Icons.link,
          controller: _ctrl.linkedinUrlCtrl,
          hint: 'https://linkedin.com/in/…',
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'GitHub URL',
          icon: Icons.code,
          controller: _ctrl.githubUrlCtrl,
          hint: 'https://github.com/…',
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Portfolio URL',
          icon: Icons.language,
          controller: _ctrl.portfolioUrlCtrl,
          hint: 'https://yoursite.com',
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'X / Twitter URL',
          icon: Icons.alternate_email,
          controller: _ctrl.twitterUrlCtrl,
          hint: 'https://x.com/…',
          accent: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Resume URL',
          icon: Icons.description_outlined,
          controller: _ctrl.resumeUrlCtrl,
          hint: 'Drive or Dropbox link',
          accent: _C.cyan,
        ),
      ],
    );
  }

  // ── FLOATING SAVE BAR ─────────────────────────────────────────────────────
  Widget _buildSaveBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: _C.bg.withValues(alpha: 0.88),
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom + 12,
            ),
            child: GestureDetector(
              onTap: _isSaving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 54,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSaving
                        ? [_C.surface, _C.surface]
                        : [_C.purple, const Color(0xFF0891B2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _isSaving
                      ? []
                      : [
                          BoxShadow(
                            color: _C.purple.withValues(alpha: 0.45),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                ),
                child: Center(
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: _C.cyan,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.save_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Save Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE FORM WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final bool required;
  final Color accent;

  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.required = false,
    this.accent = _C.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _C.textPrimary, fontSize: 14),
      validator: required
          ? (v) => v?.trim().isEmpty == true ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3D4D60), fontSize: 13),
        labelStyle: const TextStyle(color: _C.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, size: 17, color: _C.textSecondary),
        filled: true,
        fillColor: _C.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.rose),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.rose, width: 1.5),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final Color accent;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: _C.surface,
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: _C.textSecondary,
        size: 18,
      ),
      style: const TextStyle(color: _C.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _C.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, size: 17, color: _C.textSecondary),
        filled: true,
        fillColor: _C.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Select…', style: TextStyle(color: _C.textSecondary)),
        ),
        ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ],
      onChanged: onChanged,
    );
  }
}

class _RemovableChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _RemovableChip({
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 10, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GoalToggle({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: value ? color.withValues(alpha: 0.1) : _C.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? color.withValues(alpha: 0.35) : _C.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: color.withValues(alpha: value ? 0.2 : 0.07),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: value ? color : _C.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: value ? _C.textPrimary : _C.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: _C.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 44,
              height: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: value ? color : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;
  const _AddBtn({required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(Icons.add, color: color, size: 20),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color, blurRadius: 80, spreadRadius: 20)],
      ),
    );
  }
}
