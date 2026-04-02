import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:startlink/core/widgets/role_switch_dialog.dart';
import 'package:startlink/features/admin/presentation/pages/admin_dashboard_layout.dart';
import 'package:startlink/features/ai_co_founder/presentation/pages/co_founder_chat_screen.dart';
import 'package:startlink/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:startlink/features/collaboration/presentation/pages/idea_inbox_screen.dart';
import 'package:startlink/features/collaboration/presentation/screens/received_applications_screen.dart';
import 'package:startlink/features/compass/presentation/pages/compass_page.dart';
import 'package:startlink/features/compass/presentation/widgets/innovation_compass_widget.dart';
import 'package:startlink/features/debug/presentation/simulation_dashboard.dart';
import 'package:startlink/features/home/presentation/utils/dashboard_features.dart';
import 'package:startlink/features/home/presentation/widgets/empty_state.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/idea/presentation/idea_post_screen.dart';
import 'package:startlink/features/idea/presentation/pages/idea_detail_screen.dart';
import 'package:startlink/features/matching/presentation/pages/matching_page.dart';
import 'package:startlink/features/mentor/presentation/pages/mentor_reels_screen.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_profile_screen.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';

// ─── Premium Colour Palette ──────────────────────────────────────────────────
class _PremiumColors {
  static const Color accent = Color(0xFF00E5FF); // electric cyan
  static const Color accentGold = Color(0xFFFFD060); // warm gold
  static const Color accentViolet = Color(0xFF9B6DFF); // soft violet
  static const Color surface = Color(0xFF0D1117); // near-black
  static const Color surfaceCard = Color(0xFF161B22); // card base
  static const Color glass = Color(0xFF21262D); // glass layer
  static const Color border = Color(0xFF30363D); // subtle border
  static const Color textPri = Color(0xFFE6EDF3);
  static const Color textSec = Color(0xFF8B949E);

  static LinearGradient get cyanGold => const LinearGradient(
    colors: [accent, accentGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get violetCyan => const LinearGradient(
    colors: [accentViolet, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─── Animated Orb Painter ────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final double t;
  _OrbPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 – cyan
    paint.shader =
        RadialGradient(
          colors: [_PremiumColors.accent.withOpacity(0.18), Colors.transparent],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              size.width * 0.25 + math.sin(t * 0.7) * 20,
              size.height * 0.3 + math.cos(t * 0.5) * 15,
            ),
            radius: 120,
          ),
        );
    canvas.drawCircle(
      Offset(
        size.width * 0.25 + math.sin(t * 0.7) * 20,
        size.height * 0.3 + math.cos(t * 0.5) * 15,
      ),
      120,
      paint,
    );

    // Orb 2 – violet
    paint.shader =
        RadialGradient(
          colors: [
            _PremiumColors.accentViolet.withOpacity(0.14),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(
              size.width * 0.75 + math.cos(t * 0.6) * 25,
              size.height * 0.6 + math.sin(t * 0.4) * 20,
            ),
            radius: 100,
          ),
        );
    canvas.drawCircle(
      Offset(
        size.width * 0.75 + math.cos(t * 0.6) * 25,
        size.height * 0.6 + math.sin(t * 0.4) * 20,
      ),
      100,
      paint,
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ─── Animated Background ─────────────────────────────────────────────────────
class _AnimatedBackground extends StatefulWidget {
  final Widget child;
  const _AnimatedBackground({required this.child});

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Stack(
        children: [
          RepaintBoundary(
            child: CustomPaint(
              painter: _OrbPainter(_ctrl.value * math.pi * 2),
              child: const SizedBox.expand(),
            ),
          ),
          child!,
        ],
      ),
      child: widget.child,
    );
  }
}

// ─── Main Dashboard Shell ─────────────────────────────────────────────────────
class InnovatorDashboard extends StatefulWidget {
  const InnovatorDashboard({super.key});

  @override
  State<InnovatorDashboard> createState() => _InnovatorDashboardState();
}

class _InnovatorDashboardState extends State<InnovatorDashboard>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InnovatorHome(),
    const ReceivedApplicationsScreen(),
    const IdeaInboxScreen(),
    const AnalyticsScreen(),
    const MentorReelsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _onTabSelect(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _PremiumColors.surface,
      body: Stack(
        children: [
          // Ambient animated background (only on home tab)
          if (_selectedIndex == 0)
            _AnimatedBackground(child: const SizedBox.expand()),

          // Page content
          RepaintBoundary(
            child: IndexedStack(index: _selectedIndex, children: _pages),
          ),
        ],
      ),
      bottomNavigationBar: _PremiumNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onTabSelect,
      ),
    );
  }
}

// ─── Premium Nav Bar ──────────────────────────────────────────────────────────
class _PremiumNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _PremiumNavBar({required this.selectedIndex, required this.onTap});

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Home'),
    (Icons.work_history_rounded, Icons.work_history_outlined, 'Requests'),
    (Icons.chat_bubble_rounded, Icons.chat_bubble_outline, 'Messages'),
    (Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Analytics'),
    (Icons.play_circle_fill_rounded, Icons.play_circle_outline, 'Reels'),
    (Icons.person_rounded, Icons.person_outline, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: RepaintBoundary(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 80 + MediaQuery.of(context).padding.bottom,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: _PremiumColors.surfaceCard.withOpacity(0.85),
              border: const Border(
                top: BorderSide(color: _PremiumColors.border, width: 0.5),
              ),
            ),
            child: Row(
              children: List.generate(_items.length, (i) {
                final item = _items[i];
                final selected = i == selectedIndex;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    onLongPress: () {
                      if (item.$3 == 'Profile') {
                        showRoleSwitchDialog(context);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: _NavItem(
                      selectedIcon: item.$1,
                      icon: item.$2,
                      label: item.$3,
                      selected: selected,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData selectedIcon;
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.selectedIcon,
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _glow = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    if (widget.selected) _ctrl.forward();
  }

  @override
  void didUpdateWidget(_NavItem old) {
    super.didUpdateWidget(old);
    if (widget.selected && !old.selected) {
      _ctrl.forward(from: 0);
    } else if (!widget.selected && old.selected) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow halo
                if (widget.selected)
                  RepaintBoundary(
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _PremiumColors.accent.withValues(
                              alpha: _glow.value * 0.35,
                            ),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                // Pill background
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: widget.selected ? 44 : 0,
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: widget.selected
                        ? LinearGradient(
                            colors: [
                              _PremiumColors.accent.withOpacity(0.22),
                              _PremiumColors.accentViolet.withOpacity(0.14),
                            ],
                          )
                        : null,
                  ),
                ),
                Icon(
                  widget.selected ? widget.selectedIcon : widget.icon,
                  size: 22,
                  color: widget.selected
                      ? _PremiumColors.accent
                      : _PremiumColors.textSec,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w400,
              color: widget.selected
                  ? _PremiumColors.accent
                  : _PremiumColors.textSec,
              letterSpacing: 0.2,
            ),
            child: Text(widget.label),
          ),
        ],
      ),
    );
  }
}

// ─── Innovator Home ───────────────────────────────────────────────────────────
class InnovatorHome extends StatelessWidget {
  const InnovatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IdeaBloc, IdeaState>(
      builder: (context, state) {
        debugPrint('[InnovatorHome] State: $state');
        return RefreshIndicator(
          color: _PremiumColors.accent,
          backgroundColor: _PremiumColors.surfaceCard,
          onRefresh: () async {
            context.read<IdeaBloc>().add(RefreshIdeas());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              _buildTopSection(context, state),
              _buildIdeaSection(context, state),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
    );
  }

  // ── App Bar ─────────────────────────────────────────────────────────────────
  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 110,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: ClipRect(
        child: RepaintBoundary(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: _AppBarContent(),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _PremiumColors.accentViolet.withOpacity(0.10),
                      _PremiumColors.surface.withOpacity(0.90),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top Section ─────────────────────────────────────────────────────────────
  SliverToBoxAdapter _buildTopSection(BuildContext context, IdeaState state) {
    final totalIdeas = state is IdeaLoaded
        ? state.ideas.length.toString()
        : '-';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compass
            const _AnimatedSection(
              delay: Duration(milliseconds: 0),
              child: InnovationCompassWidget(),
            ),
            const SizedBox(height: 28),

            // Stats Row
            _AnimatedSection(
              delay: const Duration(milliseconds: 80),
              child: Row(
                children: [
                  Expanded(
                    child: _PremiumStatCard(
                      label: 'Ideas',
                      value: totalIdeas,
                      icon: Icons.lightbulb_rounded,
                      gradient: _PremiumColors.violetCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _PremiumStatCard(
                      label: 'Collaborators',
                      value: '17',
                      icon: Icons.groups_rounded,
                      gradient: LinearGradient(
                        colors: [Color(0xFFFFD060), Color(0xFFFF8C42)],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _PremiumStatCard(
                      label: 'Rating',
                      value: '4.8',
                      icon: Icons.star_rounded,
                      gradient: LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF0077FF)],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // Section header
            _AnimatedSection(
              delay: const Duration(milliseconds: 140),
              child: const _SectionHeader(title: 'Explore Features'),
            ),
            const SizedBox(height: 16),

            // Feature list
            _AnimatedSection(
              delay: const Duration(milliseconds: 180),
              child: _buildFeatureList(context),
            ),

            const SizedBox(height: 32),

            // Post idea CTA
            _AnimatedSection(
              delay: const Duration(milliseconds: 220),
              child: _PostIdeaButton(),
            ),

            const SizedBox(height: 36),

            // Your Ideas header
            _AnimatedSection(
              delay: const Duration(milliseconds: 260),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _SectionHeader(title: 'Your Ideas'),
                  _GlowTextButton(label: 'View All', onTap: () {}),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    final allFeatures = DashboardConfig.getAllFeatures(context);
    final features = allFeatures
        .where((f) => f.id != 'home' && f.id != 'profile' && f.id != 'idea')
        .toList();

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          return _PremiumFeatureCard(
            feature: feature,
            index: index,
            onTap: () => _navigateToFeature(context, feature),
          );
        },
      ),
    );
  }

  void _navigateToFeature(BuildContext context, DashboardFeature feature) {
    Widget? screen;
    switch (feature.id) {
      case 'simulation':
        screen = const SimulationDashboard();
        break;
      case 'analytics':
        screen = const AnalyticsScreen();
        break;
      case 'collaboration':
        screen = const ReceivedApplicationsScreen();
        break;
      case 'ai_co_founder':
        screen = const CoFounderChatScreen();
        break;
      case 'compass':
        screen = const CompassPage();
        break;
      case 'matching':
        screen = const MatchingPage();
        break;
      case 'admin':
        screen = const AdminDashboardLayout();
        break;
      default:
        if (feature.routeName != null) {
          Navigator.pushNamed(context, feature.routeName!);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _PremiumColors.glass,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Text(
              '${feature.title} coming soon!',
              style: const TextStyle(color: _PremiumColors.textPri),
            ),
          ),
        );
        return;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, __) => screen!,
        transitionsBuilder: (_, a, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  // ── Idea Section ─────────────────────────────────────────────────────────────
  Widget _buildIdeaSection(BuildContext context, IdeaState state) {
    if (state is IdeaLoading || state is IdeaInitial) {
      if (state is IdeaInitial && context.mounted) {
        context.read<IdeaBloc>().add(FetchIdeas());
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Shimmer.fromColors(
            baseColor: _PremiumColors.surfaceCard,
            highlightColor: _PremiumColors.glass,
            child: Container(
              height: 130,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: _PremiumColors.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          childCount: 3,
        ),
      );
    }

    if (state is IdeaLoaded && state.ideas.isEmpty) {
      return SliverToBoxAdapter(
        child: EmptyState(
          message:
              "You haven't posted any ideas yet.\nShare your vision with the world!",
          actionLabel: 'Post your first idea',
          onAction: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const IdeaPostScreen()),
            );
          },
        ),
      );
    }

    if (state is IdeaLoaded) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((_, index) {
          final idea = state.ideas[index];
          return _AnimatedSection(
            delay: Duration(milliseconds: index * 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: _PremiumIdeaCardWrapper(
                child: IdeaCard(
                  title: idea.title,
                  description: idea.description,
                  status: idea.status,
                  skills: idea.tags ?? [],
                  imageUrl: idea.coverImageUrl,
                  views: 0,
                  applications: 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdeaDetailScreen(idea: idea),
                      ),
                    );
                  },
                  onEdit: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => IdeaPostScreen(idea: idea),
                      ),
                    );
                    if (result == true && context.mounted) {
                      context.read<IdeaBloc>().add(RefreshIdeas());
                    }
                  },
                ),
              ),
            ),
          );
        }, childCount: state.ideas.length),
      );
    }

    if (state is IdeaError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.orangeAccent,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading ideas: ${state.message}',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

// ─── App Bar Content ──────────────────────────────────────────────────────────
class _AppBarContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            String? avatarUrl;
            String initials = 'U';
            if (state is ProfileLoaded) {
              avatarUrl = state.profile.avatarUrl;
              if (state.profile.fullName?.isNotEmpty == true) {
                final parts = state.profile.fullName!.trim().split(' ');
                initials = parts.length == 1
                    ? parts.first[0].toUpperCase()
                    : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
              }
            }

            return _AnimatedAvatar(avatarUrl: avatarUrl, initials: initials);
          },
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 11,
                  color: _PremiumColors.textSec,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              RepaintBoundary(
                child: ShaderMask(
                  shaderCallback: (bounds) =>
                      _PremiumColors.cyanGold.createShader(bounds),
                  child: const Text(
                    'Innovator',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Notification bell
        _GlowIconButton(icon: Icons.notifications_outlined, onTap: () {}),
      ],
    );
  }
}

// ─── Animated Avatar ──────────────────────────────────────────────────────────
class _AnimatedAvatar extends StatefulWidget {
  final String? avatarUrl;
  final String initials;
  const _AnimatedAvatar({required this.avatarUrl, required this.initials});

  @override
  State<_AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<_AnimatedAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: const [
              _PremiumColors.accent,
              _PremiumColors.accentViolet,
              _PremiumColors.accentGold,
              _PremiumColors.accent,
            ],
            transform: GradientRotation(_ctrl.value * math.pi * 2),
          ),
        ),
        padding: const EdgeInsets.all(2),
        child: CircleAvatar(
          backgroundColor: _PremiumColors.surfaceCard,
          backgroundImage: (widget.avatarUrl?.isNotEmpty == true)
              ? NetworkImage(widget.avatarUrl!)
              : null,
          child: (widget.avatarUrl == null || widget.avatarUrl!.isEmpty)
              ? Text(
                  widget.initials,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _PremiumColors.accent,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

// ─── Premium Stat Card ────────────────────────────────────────────────────────
class _PremiumStatCard extends StatefulWidget {
  final String label;
  final String value;
  final IconData icon;
  final LinearGradient gradient;

  const _PremiumStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  State<_PremiumStatCard> createState() => _PremiumStatCardState();
}

class _PremiumStatCardState extends State<_PremiumStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: _PremiumColors.surfaceCard,
            border: Border.all(color: _PremiumColors.border, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.colors.first.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (b) => widget.gradient.createShader(b),
                child: Icon(widget.icon, size: 22, color: Colors.white),
              ),
              const SizedBox(height: 10),
              RepaintBoundary(
                child: ShaderMask(
                  shaderCallback: (b) => widget.gradient.createShader(b),
                  child: Text(
                    widget.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 10,
                  color: _PremiumColors.textSec,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Premium Feature Card ─────────────────────────────────────────────────────
class _PremiumFeatureCard extends StatefulWidget {
  final DashboardFeature feature;
  final int index;
  final VoidCallback onTap;

  const _PremiumFeatureCard({
    required this.feature,
    required this.index,
    required this.onTap,
  });

  @override
  State<_PremiumFeatureCard> createState() => _PremiumFeatureCardState();
}

class _PremiumFeatureCardState extends State<_PremiumFeatureCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  // Cycle through accent colours per card index
  Color get _accentColor {
    const colors = [
      _PremiumColors.accent,
      _PremiumColors.accentViolet,
      _PremiumColors.accentGold,
      Color(0xFF00FF88),
      Color(0xFFFF6B6B),
    ];
    return colors[widget.index % colors.length];
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          width: 90,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: _PremiumColors.surfaceCard,
                  border: Border.all(
                    color: _accentColor.withOpacity(0.35),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.12),
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: (widget.feature.imageUrl?.isNotEmpty == true)
                      ? Image.network(
                          widget.feature.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _FeatureIcon(
                            icon: widget.feature.icon,
                            color: _accentColor,
                          ),
                        )
                      : _FeatureIcon(
                          icon: widget.feature.icon,
                          color: _accentColor,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.feature.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _PremiumColors.textSec,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _FeatureIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RepaintBoundary(
        child: ShaderMask(
          shaderCallback: (b) => LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(b),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}

// ─── Post Idea Button ─────────────────────────────────────────────────────────
class _PostIdeaButton extends StatefulWidget {
  @override
  State<_PostIdeaButton> createState() => _PostIdeaButtonState();
}

class _PostIdeaButtonState extends State<_PostIdeaButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final state = context.read<ProfileBloc>().state;
        if (state is! ProfileLoaded) return;
        if (state.profile.profileCompletion >= 70) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, a, __) => const IdeaPostScreen(),
              transitionsBuilder: (_, a, __, child) => SlideTransition(
                position: Tween(begin: const Offset(0, 0.08), end: Offset.zero)
                    .animate(
                      CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
                    ),
                child: FadeTransition(
                  opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
                  child: child,
                ),
              ),
              transitionDuration: const Duration(milliseconds: 350),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfileScreen(profile: state.profile),
            ),
          );
        }
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: SweepGradient(
              colors: const [
                _PremiumColors.accent,
                _PremiumColors.accentViolet,
                _PremiumColors.accentGold,
                _PremiumColors.accent,
              ],
              transform: GradientRotation(_ctrl.value * math.pi * 2),
            ),
            boxShadow: [
              BoxShadow(
                color: _PremiumColors.accent.withOpacity(0.30),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _PremiumColors.surfaceCard,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  child: ShaderMask(
                    shaderCallback: (b) =>
                        _PremiumColors.cyanGold.createShader(b),
                    child: const Icon(
                      Icons.add_circle_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                RepaintBoundary(
                  child: ShaderMask(
                    shaderCallback: (b) =>
                        _PremiumColors.cyanGold.createShader(b),
                    child: const Text(
                      'Post New Idea',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Premium Idea Card Wrapper ────────────────────────────────────────────────
class _PremiumIdeaCardWrapper extends StatefulWidget {
  final Widget child;
  const _PremiumIdeaCardWrapper({required this.child});

  @override
  State<_PremiumIdeaCardWrapper> createState() =>
      _PremiumIdeaCardWrapperState();
}

class _PremiumIdeaCardWrapperState extends State<_PremiumIdeaCardWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
      lowerBound: 0.975,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _PremiumColors.border.withOpacity(0.6),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: _PremiumColors.accent.withOpacity(0.04),
                blurRadius: 16,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─── Shared Helpers ───────────────────────────────────────────────────────────

/// Fade + slide-up reveal on first build
class _AnimatedSection extends StatefulWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedSection({required this.child, required this.delay});

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            gradient: _PremiumColors.violetCyan,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _PremiumColors.textPri,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _GlowTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GlowTextButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ShaderMask(
        shaderCallback: (b) => _PremiumColors.violetCyan.createShader(b),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

class _GlowIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlowIconButton({required this.icon, required this.onTap});

  @override
  State<_GlowIconButton> createState() => _GlowIconButtonState();
}

class _GlowIconButtonState extends State<_GlowIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.88,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) => _ctrl.forward(),
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _PremiumColors.glass,
            border: Border.all(color: _PremiumColors.border, width: 0.8),
          ),
          child: const Icon(
            Icons.notifications_outlined,
            color: _PremiumColors.textSec,
            size: 20,
          ),
        ),
      ),
    );
  }
}
