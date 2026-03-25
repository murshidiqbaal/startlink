// lib/features/profile/presentation/innovator_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/achievements/presentation/bloc/achievement_bloc.dart';
import 'package:startlink/features/achievements/presentation/widgets/achievement_badge.dart';
import 'package:startlink/features/aura/presentation/bloc/aura_bloc.dart';
import 'package:startlink/features/aura/presentation/widgets/aura_badge.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/innovator_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_innovator_profile.dart';
import 'package:startlink/features/trust/presentation/bloc/trust_score_bloc.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:startlink/features/verification/presentation/widgets/verification_badge_row.dart';

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
    return BlocProvider(
      create: (ctx) =>
          InnovatorProfileBloc(repository: ctx.read<ProfileRepository>())
            ..add(LoadInnovatorProfile(profile.id)),
      child: _InnovatorProfileBody(
        profile: profile,
        isCurrentUser: isCurrentUser,
      ),
    );
  }
}

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

class _InnovatorProfileBodyState extends State<_InnovatorProfileBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VerificationBloc>().add(
        FetchVerificationsAndBadges(widget.profile.id),
      );
      context.read<AuraBloc>().add(FetchAura(widget.profile.id));
      context.read<AchievementBloc>().add(FetchAchievements(widget.profile.id));
    });
  }

  Future<void> _refresh() async {
    context.read<ProfileBloc>().add(FetchProfile());
    context.read<InnovatorProfileBloc>().add(
      LoadInnovatorProfile(widget.profile.id),
    );
    context.read<VerificationBloc>().add(
      FetchVerificationsAndBadges(widget.profile.id),
    );
    context.read<AuraBloc>().add(FetchAura(widget.profile.id));
    context.read<AchievementBloc>().add(FetchAchievements(widget.profile.id));
  }

  void _goEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: EditInnovatorProfileScreen(baseProfile: widget.profile),
        ),
      ),
    ).then((updated) {
      if (updated == true && mounted) {
        _refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return BlocBuilder<InnovatorProfileBloc, InnovatorProfileState>(
      builder: (ctx, state) {
        final innov = state.profile;

        return RefreshIndicator(
          onRefresh: _refresh,
          color: AppColors.brandPurple,
          backgroundColor: AppColors.surfaceGlass,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.background,
                pinned: true,
                expandedHeight: 0,
                title: Text(
                  widget.isCurrentUser
                      ? 'My Innovator Profile'
                      : 'Innovator Profile',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: widget.isCurrentUser
                    ? [
                        IconButton(
                          icon: const Icon(
                            Icons.manage_accounts_outlined,
                            color: AppColors.brandCyan,
                          ),
                          tooltip: 'Edit Profile',
                          onPressed: _goEdit,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.logout,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(AuthLogoutRequested()),
                        ),
                      ]
                    : null,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroCard(
                        profile: p,
                        isCurrentUser: widget.isCurrentUser,
                        onEditTap: _goEdit,
                      ),
                      const SizedBox(height: 16),

                      _TrustAuraRow(profileId: p.id),
                      const SizedBox(height: 16),

                      // Verification badges
                      BlocBuilder<VerificationBloc, VerificationState>(
                        builder: (_, vs) {
                          if (vs is VerificationLoaded && vs.badges.isNotEmpty) {
                            return _SectionCard(
                              title: 'Verification',
                              icon: Icons.verified_outlined,
                              child: VerificationBadgeRow(badges: vs.badges),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      if (p.about?.isNotEmpty == true ||
                          innov?.bio?.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'About',
                          icon: Icons.person_outline,
                          child: Text(
                            innov?.bio ?? p.about ?? '',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.55,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],

                      if (innov != null) ...[
                        const SizedBox(height: 16),
                        _ProfessionalSnapshot(innov: innov),
                      ],

                      if (p.skills.isNotEmpty || innov?.skills.isNotEmpty == true) ...[
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Skills',
                          icon: Icons.bolt_outlined,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: (innov?.skills ?? p.skills)
                                .map((s) => _SkillChip(label: s))
                                .toList(),
                          ),
                        ),
                      ],

                      if (innov != null) ...[
                        const SizedBox(height: 16),
                        _StartupCredibility(innov: innov),
                        const SizedBox(height: 16),
                        _CollaborationPreferencesSection(innov: innov),
                      ],

                      if (_hasLinks(p, innov)) ...[
                        const SizedBox(height: 16),
                        _SectionCard(
                          title: 'Social & Web',
                          icon: Icons.link,
                          child: Column(
                            children: [
                              _buildLink(Icons.link, 'LinkedIn', innov?.linkedinUrl ?? p.linkedinUrl),
                              _buildLink(Icons.code, 'GitHub', innov?.githubUrl ?? p.githubUrl),
                              _buildLink(Icons.language_outlined, 'Portfolio', innov?.portfolioUrl ?? p.portfolioUrl),
                              _buildLink(Icons.alternate_email, 'X / Twitter', innov?.twitterUrl),
                            ],
                          ),
                        ),
                      ],

                      BlocBuilder<AchievementBloc, AchievementState>(
                        builder: (_, as_) {
                          if (as_ is AchievementLoaded &&
                              as_.achievements.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _SectionCard(
                                title: 'Achievements',
                                icon: Icons.emoji_events_outlined,
                                child: SizedBox(
                                  height: 110,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: as_.achievements.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 12),
                                    itemBuilder: (_, i) => AchievementBadge(
                                      achievement: as_.achievements[i],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      if (widget.isCurrentUser) ...[
                        const SizedBox(height: 24),
                        _EditCta(onTap: _goEdit),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLink(IconData icon, String label, String? url) {
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    return _LinkRow(icon: icon, label: label, url: url);
  }

  bool _hasLinks(ProfileModel p, InnovatorProfile? innov) =>
      (p.linkedinUrl?.isNotEmpty ?? false) ||
      (p.githubUrl?.isNotEmpty ?? false) ||
      (p.portfolioUrl?.isNotEmpty ?? false) ||
      (innov?.linkedinUrl?.isNotEmpty ?? false) ||
      (innov?.githubUrl?.isNotEmpty ?? false) ||
      (innov?.portfolioUrl?.isNotEmpty ?? false) ||
      (innov?.twitterUrl?.isNotEmpty ?? false);
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _ProfessionalSnapshot extends StatelessWidget {
  final InnovatorProfile innov;
  const _ProfessionalSnapshot({required this.innov});

  @override
  Widget build(BuildContext context) {
    final showExp = innov.experienceLevel != null;
    final showStatus = innov.currentStatus != null;
    final showWork = innov.preferredWorkMode != null;

    if (!showExp && !showStatus && !showWork) return const SizedBox.shrink();

    return _SectionCard(
      title: 'Professional Snapshot',
      icon: Icons.insights_outlined,
      child: Column(
        children: [
          if (showExp)
            _DataRow(label: 'Experience', value: innov.experienceLevel!),
          if (showStatus)
            _DataRow(label: 'Current Status', value: innov.currentStatus!),
          if (showWork)
            _DataRow(label: 'Preferred Mode', value: innov.preferredWorkMode!),
        ],
      ),
    );
  }
}

class _StartupCredibility extends StatelessWidget {
  final InnovatorProfile innov;
  const _StartupCredibility({required this.innov});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Startup Credibility',
      icon: Icons.rocket_launch_outlined,
      child: Column(
        children: [
          _DataRow(
            label: 'Building Startup',
            value: innov.buildingStartup ? 'Yes ✅' : 'No',
            valueColor: innov.buildingStartup ? AppColors.emerald : null,
          ),
          if (innov.buildingStartup && innov.startupName != null)
            _DataRow(label: 'Startup Name', value: innov.startupName!),
        ],
      ),
    );
  }
}

class _CollaborationPreferencesSection extends StatelessWidget {
  final InnovatorProfile innov;
  const _CollaborationPreferencesSection({required this.innov});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Collaboration Prefs',
      icon: Icons.handshake_outlined,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _PreferenceTag(
            label: 'Co-Founder',
            active: innov.openToCofounder,
            icon: Icons.people_alt_outlined,
          ),
          _PreferenceTag(
            label: 'Investors',
            active: innov.openToInvestors,
            icon: Icons.attach_money,
          ),
          _PreferenceTag(
            label: 'Mentors',
            active: innov.openToMentors,
            icon: Icons.school_outlined,
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _DataRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTag extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  const _PreferenceTag({
    required this.label,
    required this.active,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.brandPurple : AppColors.textSecondary.withValues(alpha: 0.3);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (active) ...[
            const SizedBox(width: 4),
            const Icon(Icons.check_circle, size: 12, color: AppColors.emerald),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ProfileModel profile;
  final bool isCurrentUser;
  final VoidCallback onEditTap;
  const _HeroCard({
    required this.profile,
    required this.isCurrentUser,
    required this.onEditTap,
  });

  Color get _completionColor {
    final c = profile.profileCompletion;
    if (c < 40) return AppColors.rose;
    if (c < 70) return AppColors.amber;
    return AppColors.emerald;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceGlass,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.brandPurple, AppColors.brandCyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.surfaceGlass,
                    backgroundImage: profile.avatarUrl?.isNotEmpty == true
                        ? NetworkImage(profile.avatarUrl!)
                        : null,
                    child: profile.avatarUrl?.isNotEmpty != true
                        ? Text(
                            profile.initials.isEmpty ? '?' : profile.initials,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName ?? 'User',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    if (profile.headline?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.headline!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (profile.location?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            profile.location!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    _RoleBadge(role: profile.role ?? 'Innovator'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0x0FFFFFFF)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Profile Strength',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '${profile.profileCompletion}%',
                style: TextStyle(
                  color: _completionColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: profile.profileCompletion / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(_completionColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustAuraRow extends StatelessWidget {
  final String profileId;
  const _TrustAuraRow({required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<TrustScoreBloc, TrustScoreState>(
            builder: (_, state) => _StatCard(
              icon: Icons.shield_outlined,
              label: 'Trust Score',
              value: state is TrustScoreLoaded ? state.score.toString() : '—',
              color: AppColors.amber,
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
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.surfaceGlass,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                  child: AuraBadge(
                    points: pts,
                    showLabel: true,
                    animate: false,
                  ),
                );
              }
              return const _StatCard(
                icon: Icons.auto_awesome_outlined,
                label: 'Aura',
                value: '—',
                color: AppColors.brandCyan,
              );
            },
          ),
        ),
      ],
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.surfaceGlass,
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceGlass,
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge({required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.brandPurple, AppColors.brandCyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Text(
        role,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: AppColors.brandPurple.withValues(alpha: 0.14),
      border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.35)),
    ),
    child: Text(
      label,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
    ),
  );
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  const _LinkRow({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.brandCyan),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              url.replaceAll('https://', '').replaceAll('http://', ''),
              style: const TextStyle(
                color: AppColors.brandCyan,
                fontSize: 12,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.brandCyan,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCta extends StatelessWidget {
  final VoidCallback onTap;
  const _EditCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.brandPurple.withValues(alpha: 0.15),
              AppColors.brandCyan.withValues(alpha: 0.07),
            ],
          ),
          border: Border.all(
            color: AppColors.brandPurple.withValues(alpha: 0.35),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.manage_accounts_outlined,
              color: AppColors.brandPurple,
              size: 22,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Add skills, startup details & collaboration prefs',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
