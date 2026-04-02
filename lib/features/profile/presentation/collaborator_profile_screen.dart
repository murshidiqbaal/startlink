import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_collaborator_profile.dart';

// ─── NEW SUPPORTING MODELS ───────────────────────────────────────────────────

class FeaturedProject {
  final String title;
  final String description;
  final String? url;
  final List<String> tags;
  final String? imageUrl;

  const FeaturedProject({
    required this.title,
    required this.description,
    this.url,
    this.tags = const [],
    this.imageUrl,
  });
}

class WorkHistoryItem {
  final String role;
  final String company;
  final String period;
  final String? description;

  const WorkHistoryItem({
    required this.role,
    required this.company,
    required this.period,
    this.description,
  });
}

class Certification {
  final String name;
  final String issuer;
  final String? year;

  const Certification({required this.name, required this.issuer, this.year});
}

// ─────────────────────────────────────────────────────────────────────────────

class CollaboratorProfileScreen extends StatefulWidget {
  final ProfileModel baseProfile;
  final bool isCurrentUser;

  const CollaboratorProfileScreen({
    super.key,
    required this.baseProfile,
    required this.isCurrentUser,
  });

  @override
  State<CollaboratorProfileScreen> createState() =>
      _CollaboratorProfileScreenState();
}

class _CollaboratorProfileScreenState extends State<CollaboratorProfileScreen>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _heroController;
  late final AnimationController _contentController;
  double _headerOpacity = 0;

  // ── Demo / placeholder extended data (replace with real model fields) ────
  final Map<String, int> _skills = {
    'Flutter': 95,
    'Dart': 90,
    'Firebase': 80,
    'Supabase': 85,
    'UI/UX Design': 70,
    'Node.js': 60,
  };

  final List<String> _techStack = [
    'Flutter',
    'Dart',
    'Riverpod',
    'GoRouter',
    'Supabase',
    'Firebase',
    'REST API',
    'Git',
  ];

  final List<String> _languages = ['English', 'Malayalam', 'Hindi'];

  final List<FeaturedProject> _projects = [
    FeaturedProject(
      title: 'MemoCare',
      description:
          'Dementia care app for patients & caregivers with real-time monitoring, safe-zone alerts, and cognitive games.',
      tags: ['Flutter', 'Supabase', 'Firebase'],
      url: 'https://github.com',
    ),
    FeaturedProject(
      title: 'StartLink',
      description:
          'Startup collaboration platform connecting founders with skilled collaborators across domains.',
      tags: ['Flutter', 'BLoC', 'REST API'],
      url: 'https://github.com',
    ),
    FeaturedProject(
      title: 'Campus Hub',
      description:
          'Department management tool with file uploads, event management, and student coordination.',
      tags: ['Flutter', 'Firebase', 'Hive'],
    ),
  ];

  final List<WorkHistoryItem> _workHistory = [
    WorkHistoryItem(
      role: 'Lead Flutter Developer',
      company: 'StartLink Inc.',
      period: '2024 – Present',
      description:
          'Building a collaborative startup platform with real-time features and scalable architecture.',
    ),
    WorkHistoryItem(
      role: 'Mobile App Developer',
      company: 'Freelance',
      period: '2022 – 2024',
      description:
          'Delivered 5+ Flutter apps for healthcare and education sectors.',
    ),
    WorkHistoryItem(
      role: 'Flutter Intern',
      company: 'TechVentures Kerala',
      period: '2021 – 2022',
      description:
          'Developed internal tools and prototypes using Flutter and Firebase.',
    ),
  ];

  final List<Certification> _certifications = [
    Certification(
      name: 'Flutter & Dart – The Complete Guide',
      issuer: 'Udemy',
      year: '2023',
    ),
    Certification(
      name: 'Google Associate Android Developer',
      issuer: 'Google',
      year: '2022',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentController.forward();
    });

    if (widget.isCurrentUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<RoleProfileBloc>().add(
                const LoadRoleProfile(role: 'collaborator'),
              );
        }
      });
    }
  }

  Future<void> _refresh() async {
    context.read<RoleProfileBloc>().add(
          const LoadRoleProfile(role: 'collaborator'),
        );
  }

  void _onScroll() {
    final opacity = (_scrollController.offset / 120).clamp(0.0, 1.0);
    if (opacity != _headerOpacity) setState(() => _headerOpacity = opacity);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCurrentUser) {
      return BlocBuilder<RoleProfileBloc, RoleProfileState>(
        builder: (context, state) {
          if (state is RoleProfileLoading || state is RoleProfileInitial) {
            return const Scaffold(
              backgroundColor: _C.bg,
              body: Center(child: CircularProgressIndicator(color: _C.cyan)),
            );
          }
          if (state is RoleProfileError) {
            return Scaffold(
              backgroundColor: _C.bg,
              body: Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: _C.rose),
                ),
              ),
            );
          }
          if (state is CollaboratorProfileLoaded) {
            final colab = state.collaboratorProfile;
            return _buildPortfolio(context, colab);
          }
          return const SizedBox.square(dimension: 1);
        },
      );
    }

    return BlocProvider(
      create: (ctx) => RoleProfileBloc(
        authRepository: ctx.read<AuthRepository>(),
        repository: ctx.read<ProfileRepository>(),
      )..add(const LoadRoleProfile(role: 'collaborator')),
      child: BlocBuilder<RoleProfileBloc, RoleProfileState>(
        builder: (context, state) {
          if (state is RoleProfileLoading || state is RoleProfileInitial) {
            return const Scaffold(
              backgroundColor: _C.bg,
              body: Center(child: CircularProgressIndicator(color: _C.cyan)),
            );
          }
          if (state is RoleProfileError) {
            return Scaffold(
              backgroundColor: _C.bg,
              body: Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: _C.rose),
                ),
              ),
            );
          }
          if (state is CollaboratorProfileLoaded) {
            final colab = state.collaboratorProfile;
            return _buildPortfolio(context, colab);
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        },
      ),
    );
  }

  Widget _buildPortfolio(BuildContext context, CollaboratorProfile profile) {
    return Scaffold(
      backgroundColor: _C.bg,
      body: Stack(
        children: [
          // ── Ambient background blobs ─────────────────────────────────────
          Positioned(
            top: -80,
            right: -60,
            child: _GlowBlob(color: _C.cyan.withValues(alpha: 0.12), size: 300),
          ),
          Positioned(
            top: 200,
            left: -80,
            child: _GlowBlob(
              color: _C.purple.withValues(alpha: 0.1),
              size: 250,
            ),
          ),
          // ── Scrollable content ───────────────────────────────────────────
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: _C.cyan,
              backgroundColor: _C.surfaceGlass,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
              _buildSliverHero(context, profile),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildOpenToWorkBadge(profile),
                    const SizedBox(height: 20),
                    _buildStatsBento(profile),
                    const SizedBox(height: 24),
                    if (profile.bio?.isNotEmpty ?? false) ...[
                      _buildBioSection(profile),
                      const SizedBox(height: 24),
                    ],
                    _buildSkillsSection(),
                    const SizedBox(height: 24),
                    _buildTechStackSection(),
                    const SizedBox(height: 24),
                    _buildFeaturedProjectsSection(),
                    const SizedBox(height: 24),
                    _buildAvailabilitySection(profile),
                    const SizedBox(height: 24),
                    _buildWorkHistorySection(),
                    const SizedBox(height: 24),
                    _buildCertificationsSection(),
                    const SizedBox(height: 24),
                    _buildLinksSection(profile),
                    const SizedBox(height: 24),
                    _buildLanguagesSection(),
                    const SizedBox(height: 32),
                    if (widget.isCurrentUser)
                      _buildEditButton(context, profile),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── Frosted top bar ─────────────────────────────────────────────
        _buildFrostedAppBar(context, profile),
      ],
    ),
  );
}

  // ── FROSTED APP BAR ────────────────────────────────────────────────────────
  Widget _buildFrostedAppBar(
    BuildContext context,
    CollaboratorProfile profile,
  ) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: _C.bg.withValues(alpha: _headerOpacity * 0.85),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: _C.textPrimary,
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _headerOpacity,
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          widget.baseProfile.fullName ?? 'Portfolio',
                          style: const TextStyle(
                            color: _C.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isCurrentUser)
                      IconButton(
                        icon: const Icon(
                          Icons.edit_note,
                          color: _C.cyan,
                          size: 22,
                        ),
                        onPressed: () => _navigateToEdit(
                          context,
                          (context.read<RoleProfileBloc>().state
                                  as CollaboratorProfileLoaded)
                              .collaboratorProfile,
                        ),
                      ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO SECTION ───────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildSliverHero(
    BuildContext context,
    CollaboratorProfile profile,
  ) {
    final completion = profile.profileCompletion;
    final strengthColor = completion < 40
        ? _C.rose
        : (completion < 70 ? _C.amber : _C.emerald);

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _heroController,
        builder: (context, _) {
          final anim = CurvedAnimation(
            parent: _heroController,
            curve: Curves.easeOutCubic,
          );
          return Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - anim.value)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // gradient banner
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0D1B2E), Color(0xFF111827)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, _C.bg],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // avatar + info
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 110, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _GlowAvatar(
                              initials: widget.baseProfile.initials,
                              avatarUrl: widget.baseProfile.avatarUrl,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.baseProfile.fullName ?? 'Anonymous',
                                    style: const TextStyle(
                                      color: _C.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.baseProfile.headline ??
                                        'Ready to collaborate',
                                    style: const TextStyle(
                                      color: _C.textSecondary,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _LocationRow(
                                    location: widget.baseProfile.location,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // profile strength
                        Row(
                          children: [
                            Text(
                              'PROFILE STRENGTH',
                              style: TextStyle(
                                color: _C.textSecondary.withValues(alpha: 0.7),
                                fontSize: 10,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$completion%',
                              style: TextStyle(
                                color: strengthColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _AnimatedProgressBar(
                          value: completion / 100,
                          color: strengthColor,
                        ),
                        const SizedBox(height: 20),
                        // specialties
                        if (profile.specialties.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.specialties
                                .map((s) => _SpecialtyChip(label: s))
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── OPEN TO WORK ───────────────────────────────────────────────────────────
  Widget _buildOpenToWorkBadge(CollaboratorProfile profile) {
    final isOpen =
        profile.availability?.toLowerCase().contains('available') ?? false;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: isOpen
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _C.emerald.withValues(alpha: 0.15),
                    _C.cyan.withValues(alpha: 0.08),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _C.emerald.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulseDot(color: _C.emerald),
                  const SizedBox(width: 8),
                  const Text(
                    'Open to Work',
                    style: TextStyle(
                      color: _C.emerald,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _C.emerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile.availability ?? 'Full-time',
                      style: const TextStyle(color: _C.emerald, fontSize: 11),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.square(dimension: 1),
    );
  }

  // ── STATS BENTO ────────────────────────────────────────────────────────────
  Widget _buildStatsBento(CollaboratorProfile profile) {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.0,
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              value: '${profile.experienceYears ?? 0}',
              unit: 'yrs',
              label: 'Experience',
              icon: Icons.military_tech_outlined,
              gradient: [
                _C.purple.withValues(alpha: 0.3),
                _C.purple.withValues(alpha: 0.1),
              ],
              iconColor: _C.purple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: '${_projects.length}',
              unit: '+',
              label: 'Projects',
              icon: Icons.rocket_launch_outlined,
              gradient: [
                _C.cyan.withValues(alpha: 0.3),
                _C.cyan.withValues(alpha: 0.1),
              ],
              iconColor: _C.cyan,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              value: profile.hourlyRate != null
                  ? '\$${profile.hourlyRate}'
                  : 'N/A',
              unit: profile.hourlyRate != null ? '/hr' : '',
              label: 'Rate',
              icon: Icons.monetization_on_outlined,
              gradient: [
                _C.amber.withValues(alpha: 0.3),
                _C.amber.withValues(alpha: 0.1),
              ],
              iconColor: _C.amber,
            ),
          ),
        ],
      ),
    );
  }

  // ── BIO ────────────────────────────────────────────────────────────────────
  Widget _buildBioSection(CollaboratorProfile profile) {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.05,
      child: _SectionCard(
        title: 'About',
        icon: Icons.person_outline,
        child: Text(
          profile.bio!,
          style: const TextStyle(
            color: _C.textSecondary,
            height: 1.7,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ── SKILLS ─────────────────────────────────────────────────────────────────
  Widget _buildSkillsSection() {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.1,
      child: _SectionCard(
        title: 'Skills',
        icon: Icons.psychology_outlined,
        child: Column(
          children: _skills.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _SkillBar(skill: e.key, level: e.value),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── TECH STACK ─────────────────────────────────────────────────────────────
  Widget _buildTechStackSection() {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.15,
      child: _SectionCard(
        title: 'Tech Stack',
        icon: Icons.layers_outlined,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _techStack.map((t) => _TechChip(label: t)).toList(),
        ),
      ),
    );
  }

  // ── FEATURED PROJECTS ──────────────────────────────────────────────────────
  Widget _buildFeaturedProjectsSection() {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Featured Projects', icon: Icons.work_outline),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _projects.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _ProjectCard(project: _projects[i]),
            ),
          ),
        ],
      ),
    );
  }

  // ── AVAILABILITY ───────────────────────────────────────────────────────────
  Widget _buildAvailabilitySection(CollaboratorProfile profile) {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.25,
      child: _SectionCard(
        title: 'Availability & Preferences',
        icon: Icons.event_available_outlined,
        child: Row(
          children: [
            Expanded(
              child: _InfoTile2(
                label: 'Status',
                value: profile.availability ?? 'Not set',
                icon: Icons.circle,
                iconColor:
                    profile.availability?.toLowerCase().contains('available') ??
                        false
                    ? _C.emerald
                    : _C.amber,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile2(
                label: 'Work Mode',
                value: 'Remote',
                icon: Icons.home_work_outlined,
                iconColor: _C.cyan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile2(
                label: 'Project Type',
                value: profile.preferredProjectTypes.isNotEmpty
                    ? profile.preferredProjectTypes.first
                    : 'Any',
                icon: Icons.category_outlined,
                iconColor: _C.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── WORK HISTORY ───────────────────────────────────────────────────────────
  Widget _buildWorkHistorySection() {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.3,
      child: _SectionCard(
        title: 'Work History',
        icon: Icons.work_history_outlined,
        child: Column(
          children: List.generate(_workHistory.length, (i) {
            final item = _workHistory[i];
            final isLast = i == _workHistory.length - 1;
            return _TimelineItem(item: item, isLast: isLast);
          }),
        ),
      ),
    );
  }

  // ── CERTIFICATIONS ─────────────────────────────────────────────────────────
  Widget _buildCertificationsSection() {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.35,
      child: _SectionCard(
        title: 'Certifications',
        icon: Icons.verified_outlined,
        child: Column(
          children: _certifications.map((c) => _CertRow(cert: c)).toList(),
        ),
      ),
    );
  }

  // ── LINKS ──────────────────────────────────────────────────────────────────
  Widget _buildLinksSection(CollaboratorProfile profile) {
    final links = <Map<String, dynamic>>[
      if (profile.portfolioUrl?.isNotEmpty ?? false)
        {
          'icon': Icons.language,
          'label': 'Portfolio',
          'url': profile.portfolioUrl,
        },
      if (profile.githubUrl?.isNotEmpty ?? false)
        {'icon': Icons.code, 'label': 'GitHub', 'url': profile.githubUrl},
      if (profile.linkedinUrl?.isNotEmpty ?? false)
        {'icon': Icons.link, 'label': 'LinkedIn', 'url': profile.linkedinUrl},
      if (profile.resumeUrl?.isNotEmpty ?? false)
        {
          'icon': Icons.description,
          'label': 'Resume',
          'url': profile.resumeUrl,
        },
    ];

    if (links.isEmpty) return const SizedBox.square(dimension: 1);

    return _AnimatedSection(
      controller: _contentController,
      delay: 0.4,
      child: _SectionCard(
        title: 'Links & Resources',
        icon: Icons.hub_outlined,
        child: Column(
          children: links
              .map(
                (l) => _LinkTile(
                  icon: l['icon'] as IconData,
                  label: l['label'] as String,
                  url: l['url'] as String,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  // ── LANGUAGES ─────────────────────────────────────────────────────────────
  Widget _buildLanguagesSection() {
    return _AnimatedSection(
      controller: _contentController,
      delay: 0.45,
      child: _SectionCard(
        title: 'Languages',
        icon: Icons.translate_outlined,
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _languages.map((l) => _LangChip(language: l)).toList(),
        ),
      ),
    );
  }

  // ── EDIT BUTTON ────────────────────────────────────────────────────────────
  Widget _buildEditButton(BuildContext context, CollaboratorProfile profile) {
    return GestureDetector(
      onTap: () => _navigateToEdit(context, profile),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _C.purple.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Update Portfolio',
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
    );
  }

  void _navigateToEdit(BuildContext context, CollaboratorProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditCollaboratorProfileScreen(profileId: widget.baseProfile.id),
      ),
    );
  }
}

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

// ─── REUSABLE WIDGETS ─────────────────────────────────────────────────────────

class _GlowAvatar extends StatelessWidget {
  final String? initials;
  final String? avatarUrl;

  const _GlowAvatar({this.initials, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [_C.cyan, _C.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _C.cyan.withValues(alpha: 0.35),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: _C.surface,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Text(
                initials ?? '?',
                style: const TextStyle(
                  color: _C.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              )
            : null,
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final String? location;
  const _LocationRow({this.location});

  @override
  Widget build(BuildContext context) {
    if (location == null || location!.isEmpty) return const SizedBox.square(dimension: 1);
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 12,
          color: _C.textSecondary,
        ),
        const SizedBox(width: 3),
        Text(
          location!,
          style: const TextStyle(color: _C.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}

class _AnimatedProgressBar extends StatefulWidget {
  final double value;
  final Color color;
  const _AnimatedProgressBar({required this.value, required this.color});

  @override
  State<_AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<_AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: _anim.value * widget.value,
          backgroundColor: Colors.white.withValues(alpha: 0.07),
          valueColor: AlwaysStoppedAnimation<Color>(widget.color),
          minHeight: 6,
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  const _SpecialtyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _C.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.cyan.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _C.cyan,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final Color iconColor;

  const _StatCard({
    required this.value,
    required this.unit,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: _C.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: icon),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _C.cyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _C.cyan, size: 15),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: _C.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SkillBar extends StatefulWidget {
  final String skill;
  final int level;
  const _SkillBar({required this.skill, required this.level});

  @override
  State<_SkillBar> createState() => _SkillBarState();
}

class _SkillBarState extends State<_SkillBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _anim = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(Duration(milliseconds: 600 + widget.level * 3), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.level >= 85
        ? _C.cyan
        : widget.level >= 65
        ? _C.purple
        : _C.amber;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.skill,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${(widget.level * _anim.value).round()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: widget.level / 100 * _anim.value,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  final String label;
  const _TechChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _C.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final FeaturedProject project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_C.surface, _C.purple.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.purple.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _C.purple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  color: _C.purple,
                  size: 16,
                ),
              ),
              const Spacer(),
              if (project.url != null)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _C.cyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.open_in_new,
                    color: _C.cyan,
                    size: 13,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            project.title,
            style: const TextStyle(
              color: _C.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              project.description,
              style: const TextStyle(
                color: _C.textSecondary,
                fontSize: 12,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: project.tags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _C.cyan.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      t,
                      style: const TextStyle(color: _C.cyan, fontSize: 10),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _InfoTile2 extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoTile2({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: _C.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: _C.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final WorkHistoryItem item;
  final bool isLast;
  const _TimelineItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // timeline line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.cyan,
                  boxShadow: [
                    BoxShadow(
                      color: _C.cyan.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _C.cyan.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.role,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        item.company,
                        style: const TextStyle(
                          color: _C.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: _C.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.period,
                        style: const TextStyle(
                          color: _C.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.description!,
                      style: const TextStyle(
                        color: _C.textSecondary,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CertRow extends StatelessWidget {
  final Certification cert;
  const _CertRow({required this.cert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _C.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified, color: _C.amber, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cert.name,
                  style: const TextStyle(
                    color: _C.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${cert.issuer}${cert.year != null ? " · ${cert.year}" : ""}',
                  style: const TextStyle(color: _C.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  const _LinkTile({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: _C.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _C.cyan, size: 14),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: _C.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              url.replaceAll('https://', '').replaceAll('http://', ''),
              style: const TextStyle(
                color: _C.cyan,
                fontSize: 11,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_ios,
            color: _C.textSecondary,
            size: 10,
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String language;
  const _LangChip({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _C.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.purple.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, color: _C.purple, size: 13),
          const SizedBox(width: 6),
          Text(
            language,
            style: const TextStyle(
              color: _C.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;
  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.6 * _c.value),
              blurRadius: 6 + 6 * _c.value,
              spreadRadius: 1 + 2 * _c.value,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

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

class _AnimatedSection extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _AnimatedSection({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final begin = delay;
    final end = (delay + 0.4).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = ((controller.value - begin) / (end - begin)).clamp(0.0, 1.0);
        final anim = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: anim,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - anim)),
            child: child,
          ),
        );
      },
    );
  }
}

// ─── BACKGROUND GRID PAINTER ─────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // diagonal accent lines
    final accentPaint = Paint()
      ..color = _C.cyan.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    canvas.drawLine(
      const Offset(0, 0),
      Offset(size.width, size.height),
      accentPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.4, 0),
      Offset(size.width, size.height * 0.6),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
