// lib/features/profile/presentation/innovator_profile_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/achievements/presentation/bloc/achievement_bloc.dart';
import 'package:startlink/features/achievements/presentation/widgets/achievement_badge.dart';
import 'package:startlink/features/aura/presentation/bloc/aura_bloc.dart';
import 'package:startlink/features/aura/presentation/widgets/aura_badge.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_state.dart';
import 'package:startlink/features/profile/presentation/bloc/unified_role_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_innovator_profile.dart';
import 'package:startlink/features/trust/presentation/bloc/trust_score_bloc.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:startlink/features/verification/presentation/widgets/verification_badge_row.dart';

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
class InnovatorProfileScreen extends StatelessWidget {
  final ProfileModel profile;
  final bool isCurrentUser;

  const InnovatorProfileScreen({
    super.key,
    required this.profile,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    if (isCurrentUser) {
      context.read<RoleProfileBloc>().add(
            const LoadRoleProfile(role: 'innovator'),
          );
      return _InnovatorProfileBody(
        profile: profile,
        isCurrentUser: isCurrentUser,
      );
    }

    return BlocProvider(
      create: (ctx) => RoleProfileBloc(
        authRepository: ctx.read<AuthRepository>(),
        repository: ctx.read<ProfileRepository>(),
      )..add(const LoadRoleProfile(role: 'innovator')),
      child: _InnovatorProfileBody(
        profile: profile,
        isCurrentUser: isCurrentUser,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────
class _InnovatorProfileBody extends StatefulWidget {
  final ProfileModel profile;
  final bool isCurrentUser;

  const _InnovatorProfileBody({
    required this.profile,
    required this.isCurrentUser,
  });

  @override
  State<_InnovatorProfileBody> createState() => _InnovatorProfileBodyState();
}

class _InnovatorProfileBodyState extends State<_InnovatorProfileBody>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _heroAnim;
  late final AnimationController _contentAnim;
  double _headerOpacity = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    _heroAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _contentAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentAnim.forward();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VerificationBloc>().add(
        CheckVerificationStatus(widget.profile.id, 'innovator'),
      );
      context.read<AuraBloc>().add(FetchAura(widget.profile.id));
      context.read<AchievementBloc>().add(FetchAchievements(widget.profile.id));
    });
  }

  void _onScroll() {
    final opacity = (_scrollController.offset / 120).clamp(0.0, 1.0);
    if (opacity != _headerOpacity) setState(() => _headerOpacity = opacity);
  }

  Future<void> _refresh() async {
    context.read<RoleProfileBloc>().add(
      const LoadRoleProfile(role: 'innovator'),
    );
    context.read<VerificationBloc>().add(
      CheckVerificationStatus(widget.profile.id, 'innovator'),
    );
    context.read<AuraBloc>().add(FetchAura(widget.profile.id));
    context.read<AchievementBloc>().add(FetchAchievements(widget.profile.id));
  }

  void _goEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditInnovatorProfileScreen(profileId: widget.profile.id),
      ),
    ).then((updated) {
      if (updated == true && mounted) _refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heroAnim.dispose();
    _contentAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoleProfileBloc, RoleProfileState>(
      builder: (ctx, state) {
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

        if (state is InnovatorProfileLoaded) {
          final innov = state.innovatorProfile;

          return Scaffold(
            backgroundColor: _C.bg,
            body: Stack(
              children: [
                // ── ambient blobs ───────────────────────────────────────────
                Positioned(
                  top: -80,
                  right: -60,
                  child: _GlowBlob(
                    color: _C.purple.withValues(alpha: 0.12),
                    size: 300,
                  ),
                ),
                Positioned(
                  top: 220,
                  left: -80,
                  child: _GlowBlob(
                    color: _C.cyan.withValues(alpha: 0.08),
                    size: 240,
                  ),
                ),
                // ── scrollable ─────────────────────────────────────────────
                RefreshIndicator(
                  onRefresh: _refresh,
                  color: _C.cyan,
                  backgroundColor: _C.surfaceGlass,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      _buildHeroSliver(innov),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildTrustAuraRow(),
                            const SizedBox(height: 20),
                            _buildVerificationRow(),
                            _buildAboutSection(innov),
                            _buildCollabOpenness(innov),
                            _buildStartupCard(innov),
                            _buildSnapshotBento(innov),
                            _buildSkillsSection(innov),
                            _buildAchievementsSection(),
                            _buildLinksSection(innov),
                            if (widget.isCurrentUser) ...[
                              const SizedBox(height: 24),
                              _buildEditCta(),
                            ],
                            const SizedBox(height: 20),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
                // ── frosted app bar ─────────────────────────────────────────
                _buildFrostedBar(),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── FROSTED APP BAR ───────────────────────────────────────────────────────
  Widget _buildFrostedBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            color: _C.bg.withValues(alpha: _headerOpacity * 0.9),
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
                        size: 17,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: _headerOpacity,
                        duration: const Duration(milliseconds: 150),
                        child: Text(
                          widget.profile.fullName ?? 'Innovator',
                          style: const TextStyle(
                            color: _C.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isCurrentUser) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.manage_accounts_outlined,
                          color: _C.cyan,
                          size: 21,
                        ),
                        onPressed: _goEdit,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.logout,
                          color: _C.textSecondary,
                          size: 19,
                        ),
                        onPressed: () =>
                            context.read<AuthBloc>().add(AuthLogoutRequested()),
                      ),
                    ],
                    const SizedBox(width: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── HERO SLIVER ───────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildHeroSliver(InnovatorProfile innov) {
    final p = widget.profile;
    final completion = p.profileCompletion;
    final strengthColor = completion < 40
        ? _C.rose
        : completion < 70
        ? _C.amber
        : _C.emerald;

    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _heroAnim,
        builder: (_, __) {
          final anim = CurvedAnimation(
            parent: _heroAnim,
            curve: Curves.easeOutCubic,
          );
          return Opacity(
            opacity: anim.value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - anim.value)),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // banner
                  Container(
                    height: 190,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0A1020), Color(0xFF111827)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _GridPainter()),
                        ),
                        // purple glow top-right
                        Positioned(
                          top: -30,
                          right: -20,
                          child: _GlowBlob(
                            color: _C.purple.withValues(alpha: 0.18),
                            size: 200,
                          ),
                        ),
                        Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 70,
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
                  // avatar + name
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _GlowAvatar(
                              initials: p.initials,
                              avatarUrl: p.avatarUrl,
                              glowColor: _C.purple,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          p.fullName ?? 'Innovator',
                                          style: const TextStyle(
                                            color: _C.textPrimary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _RolePill(role: p.role ?? 'Innovator'),
                                    ],
                                  ),
                                  if (p.headline?.isNotEmpty == true) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      p.headline!,
                                      style: const TextStyle(
                                        color: _C.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                  if (p.location?.isNotEmpty == true) ...[
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 12,
                                          color: _C.textSecondary,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          p.location!,
                                          style: const TextStyle(
                                            color: _C.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // startup badge (if building)
                        if (innov.buildingStartup && innov.startupName != null)
                          _StartupBadge(name: innov.startupName!),
                        if (innov.buildingStartup && innov.startupName != null)
                          const SizedBox(height: 14),
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
                        _AnimatedBar(
                          value: completion / 100,
                          color: strengthColor,
                        ),
                        const SizedBox(height: 20),
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

  // ── TRUST + AURA ──────────────────────────────────────────────────────────
  Widget _buildTrustAuraRow() {
    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.0,
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<TrustScoreBloc, TrustScoreState>(
              builder: (_, state) => _MiniStatCard(
                icon: Icons.shield_outlined,
                label: 'Trust Score',
                value: state is TrustScoreLoaded ? '${state.score}' : '—',
                color: _C.amber,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocBuilder<AuraBloc, AuraState>(
              builder: (_, state) {
                final pts = state is AuraLoaded ? state.totalPoints : null;
                if (pts != null) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _C.surfaceGlass,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _C.border),
                    ),
                    child: AuraBadge(
                      points: pts,
                      showLabel: true,
                      animate: false,
                    ),
                  );
                }
                return const _MiniStatCard(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Aura Points',
                  value: '—',
                  color: _C.cyan,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── VERIFICATION ──────────────────────────────────────────────────────────
  Widget _buildVerificationRow() {
    return BlocBuilder<VerificationBloc, VerificationState>(
      builder: (_, vs) {
        if (vs is VerificationApproved && vs.badges.isNotEmpty) {
          return _FadeSlide(
            controller: _contentAnim,
            delay: 0.05,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _SectionCard(
                title: 'Verification',
                icon: Icons.verified_outlined,
                accent: _C.cyan,
                child: VerificationBadgeRow(badges: vs.badges),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── ABOUT ─────────────────────────────────────────────────────────────────
  Widget _buildAboutSection(InnovatorProfile innov) {
    final bio = innov.bio ?? widget.profile.about ?? '';
    if (bio.isEmpty) return const SizedBox.shrink();
    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.1,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _SectionCard(
          title: 'About',
          icon: Icons.person_outline,
          accent: _C.purple,
          child: Text(
            bio,
            style: const TextStyle(
              color: _C.textSecondary,
              height: 1.7,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ── COLLAB OPENNESS BADGES ────────────────────────────────────────────────
  Widget _buildCollabOpenness(InnovatorProfile innov) {
    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.15,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _SectionCard(
          title: 'Open To',
          icon: Icons.handshake_outlined,
          accent: _C.cyan,
          child: Row(
            children: [
              Expanded(
                child: _OpenTag(
                  label: 'Co-Founder',
                  icon: Icons.people_alt_outlined,
                  active: innov.openToCofounder,
                  color: _C.purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OpenTag(
                  label: 'Investors',
                  icon: Icons.attach_money,
                  active: innov.openToInvestors,
                  color: _C.emerald,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OpenTag(
                  label: 'Mentors',
                  icon: Icons.school_outlined,
                  active: innov.openToMentors,
                  color: _C.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── STARTUP CARD ──────────────────────────────────────────────────────────
  Widget _buildStartupCard(InnovatorProfile innov) {
    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.2,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _C.purple.withValues(alpha: 0.18),
                _C.cyan.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _C.purple.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _C.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  color: _C.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          innov.buildingStartup
                              ? 'Building a Startup'
                              : 'Not Building Right Now',
                          style: TextStyle(
                            color: innov.buildingStartup
                                ? _C.textPrimary
                                : _C.textSecondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (innov.buildingStartup)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _C.emerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                color: _C.emerald,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (innov.buildingStartup && innov.startupName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        innov.startupName!,
                        style: const TextStyle(
                          color: _C.cyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PROFESSIONAL SNAPSHOT BENTO ───────────────────────────────────────────
  Widget _buildSnapshotBento(InnovatorProfile innov) {
    final items = <Map<String, dynamic>>[
      if (innov.experienceLevel != null)
        {
          'label': 'Experience',
          'value': innov.experienceLevel!,
          'icon': Icons.trending_up,
          'color': _C.purple,
        },
      if (innov.currentStatus != null)
        {
          'label': 'Status',
          'value': innov.currentStatus!,
          'icon': Icons.work_outline,
          'color': _C.cyan,
        },
      if (innov.preferredWorkMode != null)
        {
          'label': 'Work Mode',
          'value': innov.preferredWorkMode!,
          'icon': Icons.home_work_outlined,
          'color': _C.amber,
        },
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.25,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Row(
          children: items.asMap().entries.map((e) {
            final item = e.value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: e.key == 0 ? 0 : 10),
                child: _BentoTile(
                  label: item['label'] as String,
                  value: item['value'] as String,
                  icon: item['icon'] as IconData,
                  color: item['color'] as Color,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── SKILLS ────────────────────────────────────────────────────────────────
  Widget _buildSkillsSection(InnovatorProfile innov) {
    final skills = innov.skills.isNotEmpty
        ? innov.skills
        : widget.profile.skills;
    if (skills.isEmpty) return const SizedBox.shrink();

    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.3,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _SectionCard(
          title: 'Skills',
          icon: Icons.bolt_outlined,
          accent: _C.cyan,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((s) => _SkillPill(label: s)).toList(),
          ),
        ),
      ),
    );
  }

  // ── ACHIEVEMENTS ──────────────────────────────────────────────────────────
  Widget _buildAchievementsSection() {
    return BlocBuilder<AchievementBloc, AchievementState>(
      builder: (_, state) {
        if (state is AchievementLoaded && state.achievements.isNotEmpty) {
          return _FadeSlide(
            controller: _contentAnim,
            delay: 0.35,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _SectionCard(
                title: 'Achievements',
                icon: Icons.emoji_events_outlined,
                accent: _C.amber,
                child: SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.achievements.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) =>
                        AchievementBadge(achievement: state.achievements[i]),
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // ── LINKS ─────────────────────────────────────────────────────────────────
  Widget _buildLinksSection(InnovatorProfile innov) {
    final p = widget.profile;
    final links = <Map<String, dynamic>>[
      if ((innov.linkedinUrl ?? p.linkedinUrl)?.isNotEmpty == true)
        {
          'icon': Icons.link,
          'label': 'LinkedIn',
          'url': innov.linkedinUrl ?? p.linkedinUrl,
        },
      if ((innov.githubUrl ?? p.githubUrl)?.isNotEmpty == true)
        {
          'icon': Icons.code,
          'label': 'GitHub',
          'url': innov.githubUrl ?? p.githubUrl,
        },
      if ((innov.portfolioUrl ?? p.portfolioUrl)?.isNotEmpty == true)
        {
          'icon': Icons.language,
          'label': 'Portfolio',
          'url': innov.portfolioUrl ?? p.portfolioUrl,
        },
      if (innov.twitterUrl?.isNotEmpty == true)
        {
          'icon': Icons.alternate_email,
          'label': 'X / Twitter',
          'url': innov.twitterUrl,
        },
    ];
    if (links.isEmpty) return const SizedBox.shrink();

    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.4,
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _SectionCard(
          title: 'Social & Web',
          icon: Icons.hub_outlined,
          accent: _C.cyan,
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
      ),
    );
  }

  // ── EDIT CTA ──────────────────────────────────────────────────────────────
  Widget _buildEditCta() {
    return _FadeSlide(
      controller: _contentAnim,
      delay: 0.45,
      child: GestureDetector(
        onTap: _goEdit,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_C.purple, Color(0xFF0891B2)],
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
              Icon(
                Icons.manage_accounts_outlined,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                'Update Innovator Profile',
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _C.surfaceGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accent, size: 14),
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
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: _C.textSecondary, fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BentoTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: _C.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            maxLines: 2,
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

class _OpenTag extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color color;

  const _OpenTag({
    required this.label,
    required this.icon,
    required this.active,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = active ? color : _C.textSecondary.withValues(alpha: 0.3);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: c),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? _C.textPrimary : _C.textSecondary,
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          if (active) ...[
            const SizedBox(height: 3),
            Icon(Icons.check_circle, size: 12, color: _C.emerald),
          ],
        ],
      ),
    );
  }
}

class _SkillPill extends StatelessWidget {
  final String label;
  const _SkillPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _C.purple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _C.purple.withValues(alpha: 0.25)),
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

class _StartupBadge extends StatelessWidget {
  final String name;
  const _StartupBadge({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _C.purple.withValues(alpha: 0.2),
            _C.cyan.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.purple.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rocket_launch_outlined, size: 13, color: _C.cyan),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              color: _C.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final String role;
  const _RolePill({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [_C.purple, _C.cyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
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
                decorationColor: _C.cyan,
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

class _GlowAvatar extends StatelessWidget {
  final String? initials;
  final String? avatarUrl;
  final Color glowColor;

  const _GlowAvatar({this.initials, this.avatarUrl, this.glowColor = _C.cyan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [glowColor, _C.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: _C.surface,
        backgroundImage: avatarUrl?.isNotEmpty == true
            ? NetworkImage(avatarUrl!)
            : null,
        child: avatarUrl?.isNotEmpty != true
            ? Text(
                initials?.isEmpty == false ? initials! : '?',
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

class _AnimatedBar extends StatefulWidget {
  final double value;
  final Color color;
  const _AnimatedBar({required this.value, required this.color});

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar>
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

class _FadeSlide extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _FadeSlide({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.4).clamp(0.0, 1.0);
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = ((controller.value - delay) / (end - delay)).clamp(0.0, 1.0);
        final v = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - v)),
            child: child,
          ),
        );
      },
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

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;
    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final accent = Paint()
      ..color = _C.purple.withValues(alpha: 0.07)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), accent);
  }

  @override
  bool shouldRepaint(_) => false;
}
