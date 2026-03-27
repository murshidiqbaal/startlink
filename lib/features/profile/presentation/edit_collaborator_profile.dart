// lib/features/profile/presentation/edit_collaborator_profile.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/controllers/collaborator_edit_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DESIGN TOKENS
// ─────────────────────────────────────────────────────────────────────────────
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
// MODELS for new fields
// ─────────────────────────────────────────────────────────────────────────────
class _Project {
  String title;
  String description;
  String url;
  List<String> tags;
  _Project({
    this.title = '',
    this.description = '',
    this.url = '',
    List<String>? tags,
  }) : tags = tags ?? [];
}

class _WorkItem {
  String role;
  String company;
  String period;
  String description;
  _WorkItem({
    this.role = '',
    this.company = '',
    this.period = '',
    this.description = '',
  });
}

class _Cert {
  String name;
  String issuer;
  String year;
  _Cert({this.name = '', this.issuer = '', this.year = ''});
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
class EditCollaboratorProfileScreen extends StatelessWidget {
  final String profileId;
  const EditCollaboratorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    context.read<RoleProfileBloc>().add(
          const LoadRoleProfile(role: 'collaborator'),
        );
    return _EditForm(profileId: profileId);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM
// ─────────────────────────────────────────────────────────────────────────────
class _EditForm extends StatefulWidget {
  final String profileId;
  const _EditForm({required this.profileId});

  @override
  State<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends State<_EditForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _controller = CollaboratorEditController();
  final _scrollController = ScrollController();
  late final AnimationController _animController;

  // ── new field state ──────────────────────────────────────────────────────
  final Map<String, int> _skills = {};
  final _skillNameCtrl = TextEditingController();
  int _skillLevel = 80;

  final List<String> _techStack = [];
  final _techCtrl = TextEditingController();

  final List<String> _languages = [];
  final _langCtrl = TextEditingController();

  String? _workMode;

  final List<_Project> _projects = [];
  final List<_WorkItem> _workHistory = [];
  final List<_Cert> _certifications = [];

  // ── section expand state ─────────────────────────────────────────────────
  final Map<int, bool> _expanded = {
    0: true,
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animController.dispose();
    _skillNameCtrl.dispose();
    _techCtrl.dispose();
    _langCtrl.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────
  void _addTag(TextEditingController ctrl, List<String> list) {
    final s = ctrl.text.trim();
    if (s.isNotEmpty && !list.contains(s)) {
      setState(() {
        list.add(s);
        ctrl.clear();
      });
    }
  }

  void _addSkill() {
    final name = _skillNameCtrl.text.trim();
    if (name.isNotEmpty && !_skills.containsKey(name)) {
      setState(() {
        _skills[name] = _skillLevel;
        _skillNameCtrl.clear();
        _skillLevel = 80;
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();
    // TODO: dispatch save event through your BLoC
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() => _isSaving = false);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // ambient glow
          Positioned(
            top: -60,
            right: -40,
            child: _Blob(color: _C.cyan.withValues(alpha: 0.08), size: 280),
          ),
          Positioned(
            bottom: 100,
            left: -60,
            child: _Blob(color: _C.purple.withValues(alpha: 0.07), size: 240),
          ),
          // main content
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
                      _buildProgressHeader(),
                      const SizedBox(height: 20),
                      _buildAccordion(
                        0,
                        'Personal Info',
                        Icons.person_outline,
                        _C.cyan,
                        _buildPersonalSection(),
                      ),
                      _buildAccordion(
                        1,
                        'Expertise & Specialties',
                        Icons.psychology_outlined,
                        _C.purple,
                        _buildExpertiseSection(),
                      ),
                      _buildAccordion(
                        2,
                        'Skills & Tech Stack',
                        Icons.layers_outlined,
                        _C.amber,
                        _buildSkillsSection(),
                      ),
                      _buildAccordion(
                        3,
                        'Experience & Rate',
                        Icons.work_outline,
                        _C.emerald,
                        _buildExperienceSection(),
                      ),
                      _buildAccordion(
                        4,
                        'Featured Projects',
                        Icons.rocket_launch_outlined,
                        _C.cyan,
                        _buildProjectsSection(),
                      ),
                      _buildAccordion(
                        5,
                        'Work History',
                        Icons.work_history_outlined,
                        _C.purple,
                        _buildWorkHistorySection(),
                      ),
                      _buildAccordion(
                        6,
                        'Certifications & Links',
                        Icons.verified_outlined,
                        _C.amber,
                        _buildCertsAndLinksSection(),
                      ),
                      const SizedBox(height: 12),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          // floating save bar
          _buildFloatingSaveBar(),
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
              Icons.edit_outlined,
              size: 15,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Edit Portfolio',
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

  // ── PROGRESS HEADER ───────────────────────────────────────────────────────
  Widget _buildProgressHeader() {
    final filled = _expanded.keys.length;
    final completed = [
      _controller.nameCtrl.text.isNotEmpty,
      _controller.specialties.isNotEmpty,
      _skills.isNotEmpty,
      _controller.yoeCtrl.text.isNotEmpty,
      _projects.isNotEmpty,
      _workHistory.isNotEmpty,
      _certifications.isNotEmpty,
    ].where((e) => e).length;
    final pct = (completed / filled * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.purple.withValues(alpha: 0.15),
            _C.cyan.withValues(alpha: 0.08),
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
                'Portfolio Completion',
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
          Text(
            '$completed of $filled sections filled · Complete your portfolio to attract better collaborations',
            style: const TextStyle(color: _C.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── ACCORDION WRAPPER ─────────────────────────────────────────────────────
  Widget _buildAccordion(
    int index,
    String title,
    IconData icon,
    Color accent,
    Widget content,
  ) {
    final open = _expanded[index] ?? false;
    return AnimatedBuilder(
      animation: _animController,
      builder: (_, __) {
        final t =
            (((_animController.value - index * 0.1).clamp(0.0, 0.4)) / 0.4);
        final anim = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: anim,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim)),
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
                  // header tap
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
                  // expandable content
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
          controller: _controller.nameCtrl,
          required: true,
          accentColor: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Short Headline',
          icon: Icons.title,
          controller: _controller.aboutCtrl,
          hint: 'e.g. Flutter Developer · UI Enthusiast',
          accentColor: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'About / Bio',
          icon: Icons.description_outlined,
          controller: _controller.bioCtrl,
          hint: 'Tell the world about yourself…',
          maxLines: 4,
          accentColor: _C.cyan,
        ),
        const SizedBox(height: 12),
        _Dropdown(
          label: 'Work Mode',
          icon: Icons.home_work_outlined,
          value: _workMode,
          items: const ['Remote', 'Hybrid', 'On-site'],
          accentColor: _C.cyan,
          onChanged: (v) => setState(() => _workMode = v),
        ),
      ],
    );
  }

  // ── SECTION: EXPERTISE ────────────────────────────────────────────────────
  Widget _buildExpertiseSection() {
    return Column(
      children: [
        _TagInputRow(
          label: 'Specialties',
          icon: Icons.star_outline,
          accentColor: _C.purple,
          controller: _controller.specInputCtrl,
          tags: _controller.specialties,
          onAdd: () =>
              _addTag(_controller.specInputCtrl, _controller.specialties),
          onRemove: (s) => setState(() => _controller.specialties.remove(s)),
          hint: 'e.g. Mobile Development',
        ),
        const SizedBox(height: 16),
        _TagInputRow(
          label: 'Preferred Project Types',
          icon: Icons.folder_open,
          accentColor: _C.purple,
          controller: _controller.projTypeInputCtrl,
          tags: _controller.preferredProjectTypes,
          onAdd: () => _addTag(
            _controller.projTypeInputCtrl,
            _controller.preferredProjectTypes,
          ),
          onRemove: (s) =>
              setState(() => _controller.preferredProjectTypes.remove(s)),
          hint: 'e.g. SaaS, Mobile App',
        ),
      ],
    );
  }

  // ── SECTION: SKILLS & TECH STACK ─────────────────────────────────────────
  Widget _buildSkillsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // skill name + add
        Row(
          children: [
            Expanded(
              child: _Field(
                label: 'Skill Name',
                icon: Icons.code,
                controller: _skillNameCtrl,
                hint: 'e.g. Flutter',
                accentColor: _C.amber,
              ),
            ),
            const SizedBox(width: 10),
            _AddButton(onTap: _addSkill, color: _C.amber),
          ],
        ),
        const SizedBox(height: 12),
        // level slider
        Row(
          children: [
            const Text(
              'Level',
              style: TextStyle(color: _C.textSecondary, fontSize: 12),
            ),
            const Spacer(),
            Text(
              '$_skillLevel%',
              style: const TextStyle(
                color: _C.amber,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _C.amber,
            inactiveTrackColor: _C.amber.withValues(alpha: 0.15),
            thumbColor: _C.amber,
            overlayColor: _C.amber.withValues(alpha: 0.1),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _skillLevel.toDouble(),
            min: 0,
            max: 100,
            divisions: 20,
            onChanged: (v) => setState(() => _skillLevel = v.round()),
          ),
        ),
        if (_skills.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._skills.entries.map(
            (e) => _SkillRow(
              skill: e.key,
              level: e.value,
              onDelete: () => setState(() => _skills.remove(e.key)),
            ),
          ),
        ],
        const SizedBox(height: 16),
        const _Label(text: 'Tech Stack'),
        const SizedBox(height: 8),
        _TagInputRow(
          label: 'Add Technology',
          icon: Icons.layers_outlined,
          accentColor: _C.amber,
          controller: _techCtrl,
          tags: _techStack,
          onAdd: () => _addTag(_techCtrl, _techStack),
          onRemove: (s) => setState(() => _techStack.remove(s)),
          hint: 'e.g. Riverpod, GoRouter',
          tagColor: _C.amber,
        ),
        const SizedBox(height: 16),
        const _Label(text: 'Languages'),
        const SizedBox(height: 8),
        _TagInputRow(
          label: 'Add Language',
          icon: Icons.translate_outlined,
          accentColor: _C.emerald,
          controller: _langCtrl,
          tags: _languages,
          onAdd: () => _addTag(_langCtrl, _languages),
          onRemove: (s) => setState(() => _languages.remove(s)),
          hint: 'e.g. English, Malayalam',
          tagColor: _C.emerald,
        ),
      ],
    );
  }

  // ── SECTION: EXPERIENCE & RATE ────────────────────────────────────────────
  Widget _buildExperienceSection() {
    return Column(
      children: [
        _Field(
          label: 'Years of Experience',
          icon: Icons.military_tech_outlined,
          controller: _controller.yoeCtrl,
          keyboardType: TextInputType.number,
          required: true,
          accentColor: _C.emerald,
        ),
        const SizedBox(height: 12),
        _Field(
          label: 'Hourly Rate (\$)',
          icon: Icons.monetization_on_outlined,
          controller: _controller.hourlyRateCtrl,
          keyboardType: TextInputType.number,
          hint: 'e.g. 35',
          accentColor: _C.emerald,
        ),
        const SizedBox(height: 12),
        _Dropdown(
          label: 'Availability',
          icon: Icons.event_available_outlined,
          value: _controller.availability,
          items: const [
            'Full-time',
            'Part-time',
            'Freelance',
            'Contract',
            'Not Available',
          ],
          accentColor: _C.emerald,
          onChanged: (v) => setState(() => _controller.availability = v),
        ),
      ],
    );
  }

  // ── SECTION: PROJECTS ─────────────────────────────────────────────────────
  Widget _buildProjectsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._projects.asMap().entries.map(
          (e) => _ProjectCard(
            project: e.value,
            index: e.key,
            onDelete: () => setState(() => _projects.removeAt(e.key)),
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        _OutlineButton(
          label: 'Add Project',
          icon: Icons.add_circle_outline,
          color: _C.cyan,
          onTap: () => setState(() => _projects.add(_Project())),
        ),
      ],
    );
  }

  // ── SECTION: WORK HISTORY ─────────────────────────────────────────────────
  Widget _buildWorkHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._workHistory.asMap().entries.map(
          (e) => _WorkCard(
            item: e.value,
            index: e.key,
            onDelete: () => setState(() => _workHistory.removeAt(e.key)),
            onChanged: () => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        _OutlineButton(
          label: 'Add Work Experience',
          icon: Icons.add_circle_outline,
          color: _C.purple,
          onTap: () => setState(() => _workHistory.add(_WorkItem())),
        ),
      ],
    );
  }

  // ── SECTION: CERTS & LINKS ────────────────────────────────────────────────
  Widget _buildCertsAndLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label(text: 'Certifications'),
        const SizedBox(height: 10),
        ..._certifications.asMap().entries.map(
          (e) => _CertCard(
            cert: e.value,
            index: e.key,
            onDelete: () => setState(() => _certifications.removeAt(e.key)),
            onChanged: () => setState(() {}),
          ),
        ),
        _OutlineButton(
          label: 'Add Certification',
          icon: Icons.add_circle_outline,
          color: _C.amber,
          onTap: () => setState(() => _certifications.add(_Cert())),
        ),
        const SizedBox(height: 20),
        const _Label(text: 'Professional Links'),
        const SizedBox(height: 10),
        _Field(
          label: 'Portfolio URL',
          icon: Icons.language,
          controller: _controller.portfolioUrlCtrl,
          hint: 'https://yourportfolio.com',
          accentColor: _C.amber,
        ),
        const SizedBox(height: 10),
        _Field(
          label: 'GitHub URL',
          icon: Icons.code,
          controller: _controller.githubUrlCtrl,
          hint: 'https://github.com/username',
          accentColor: _C.amber,
        ),
        const SizedBox(height: 10),
        _Field(
          label: 'LinkedIn URL',
          icon: Icons.link,
          controller: _controller.linkedinUrlCtrl,
          hint: 'https://linkedin.com/in/username',
          accentColor: _C.amber,
        ),
        const SizedBox(height: 10),
        _Field(
          label: 'Resume URL',
          icon: Icons.description_outlined,
          controller: _controller.resumeUrlCtrl,
          hint: 'Drive or Dropbox link',
          accentColor: _C.amber,
        ),
      ],
    );
  }

  // ── FLOATING SAVE BAR ─────────────────────────────────────────────────────
  Widget _buildFloatingSaveBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: _C.bg.withValues(alpha: 0.85),
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
                              'Save Portfolio',
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
  final TextInputType keyboardType;
  final bool required;
  final Color accentColor;

  const _Field({
    required this.label,
    required this.icon,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.required = false,
    this.accentColor = _C.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: _C.textPrimary, fontSize: 14),
      validator: required
          ? (v) => v?.trim().isEmpty == true ? 'Required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4A5568), fontSize: 13),
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
          borderSide: BorderSide(color: accentColor, width: 1.5),
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
  final Color accentColor;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.accentColor,
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
          borderSide: BorderSide(color: accentColor, width: 1.5),
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

class _TagInputRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final TextEditingController controller;
  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final String hint;
  final Color? tagColor;

  const _TagInputRow({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.controller,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
    this.hint = '',
    this.tagColor,
  });

  @override
  Widget build(BuildContext context) {
    final tc = tagColor ?? accentColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _Field(
                label: label,
                icon: icon,
                controller: controller,
                hint: hint,
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            _AddButton(onTap: onAdd, color: accentColor),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map(
                  (t) => _RemovableTag(
                    label: t,
                    color: tc,
                    onRemove: () => onRemove(t),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _RemovableTag extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _RemovableTag({
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

class _SkillRow extends StatelessWidget {
  final String skill;
  final int level;
  final VoidCallback onDelete;

  const _SkillRow({
    required this.skill,
    required this.level,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = level >= 85
        ? _C.cyan
        : level >= 65
        ? _C.purple
        : _C.amber;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        color: _C.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$level%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: level / 100,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: _C.rose.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline, color: _C.rose, size: 15),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final _Project project;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _ProjectCard({
    required this.project,
    required this.index,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.cyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _C.cyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  color: _C.cyan,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Project ${index + 1}',
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _C.rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: _C.rose,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InlineField(
            hint: 'Project title',
            value: project.title,
            onChanged: (v) {
              project.title = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _InlineField(
            hint: 'Short description',
            value: project.description,
            maxLines: 2,
            onChanged: (v) {
              project.description = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _InlineField(
            hint: 'Project URL (optional)',
            value: project.url,
            onChanged: (v) {
              project.url = v;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  final _WorkItem item;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _WorkCard({
    required this.item,
    required this.index,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _C.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work_history_outlined,
                  color: _C.purple,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Experience ${index + 1}',
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _C.rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: _C.rose,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InlineField(
            hint: 'Job Title / Role',
            value: item.role,
            onChanged: (v) {
              item.role = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _InlineField(
            hint: 'Company Name',
            value: item.company,
            onChanged: (v) {
              item.company = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _InlineField(
            hint: 'Period  (e.g. 2023 – Present)',
            value: item.period,
            onChanged: (v) {
              item.period = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          _InlineField(
            hint: 'Short description (optional)',
            value: item.description,
            maxLines: 2,
            onChanged: (v) {
              item.description = v;
              onChanged();
            },
          ),
        ],
      ),
    );
  }
}

class _CertCard extends StatelessWidget {
  final _Cert cert;
  final int index;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  const _CertCard({
    required this.cert,
    required this.index,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _C.amber.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _C.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: _C.amber,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Certification ${index + 1}',
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: _C.rose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color: _C.rose,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InlineField(
            hint: 'Certificate Name',
            value: cert.name,
            onChanged: (v) {
              cert.name = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _InlineField(
                  hint: 'Issuer',
                  value: cert.issuer,
                  onChanged: (v) {
                    cert.issuer = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 90,
                child: _InlineField(
                  hint: 'Year',
                  value: cert.year,
                  onChanged: (v) {
                    cert.year = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── MICRO WIDGETS ─────────────────────────────────────────────────────────────

class _InlineField extends StatelessWidget {
  final String hint;
  final String value;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _InlineField({
    required this.hint,
    required this.value,
    this.maxLines = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: _C.textPrimary, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3D4D60), fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        filled: true,
        fillColor: _C.surfaceGlass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _C.cyan, width: 1.2),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color color;

  const _AddButton({required this.onTap, required this.color});

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

class _OutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: _C.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
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
