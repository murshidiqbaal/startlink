import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:startlink/core/presentation/widgets/startlink_button.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/admin/presentation/pages/admin_dashboard_layout.dart';
import 'package:startlink/features/ai_co_founder/presentation/pages/co_founder_chat_screen.dart';
import 'package:startlink/features/collaboration/presentation/screens/received_applications_screen.dart';
import 'package:startlink/features/compass/presentation/pages/compass_page.dart';
import 'package:startlink/features/compass/presentation/widgets/innovation_compass_widget.dart';
import 'package:startlink/features/debug/presentation/simulation_dashboard.dart';
import 'package:startlink/features/home/presentation/utils/dashboard_features.dart';
import 'package:startlink/features/home/presentation/widgets/empty_state.dart';
import 'package:startlink/features/home/presentation/widgets/idea_card.dart';
import 'package:startlink/features/home/presentation/widgets/role_aware_navigation_bar.dart';
import 'package:startlink/features/home/presentation/widgets/stats_card.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_bloc.dart';
import 'package:startlink/features/idea/presentation/idea_post_screen.dart';
import 'package:startlink/features/idea/presentation/pages/idea_detail_screen.dart';
import 'package:startlink/features/matching/presentation/pages/matching_page.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_state.dart';
import 'package:startlink/features/profile/presentation/edit_profile_screen.dart';
import 'package:startlink/features/profile/presentation/profile_screen.dart';
import 'package:startlink/features/collaboration/presentation/pages/idea_inbox_screen.dart';

class InnovatorDashboard extends StatefulWidget {
  const InnovatorDashboard({super.key});

  @override
  State<InnovatorDashboard> createState() => _InnovatorDashboardState();
}

class _InnovatorDashboardState extends State<InnovatorDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const InnovatorHome(),
    const ReceivedApplicationsScreen(),
    const IdeaInboxScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: RoleAwareNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.work_history_outlined),
            selectedIcon: Icon(Icons.work_history),
            label: 'Requests',
          ),
          NavigationDestination(
            icon: Icon(Icons.message_outlined),
            selectedIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class InnovatorHome extends StatelessWidget {
  const InnovatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IdeaBloc, IdeaState>(
      builder: (context, state) {
        return RefreshIndicator(
          color: AppColors.brandCyan,
          backgroundColor: AppColors.surfaceGlass,
          onRefresh: () async {
            context.read<IdeaBloc>().add(RefreshIdeas());
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              _buildTopSection(context, state),
              _buildIdeaSection(context, state),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      expandedHeight: 100,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
        title: Row(
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

                return CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.surfaceGlass,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: (avatarUrl == null || avatarUrl.isEmpty)
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.brandCyan,
                          ),
                        )
                      : null,
                );
              },
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  'Innovator', // Placeholder for Name
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.brandPurple.withValues(alpha: 0.15),
                AppColors.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTopSection(BuildContext context, IdeaState state) {
    final totalIdeas = state is IdeaLoaded
        ? state.ideas.length.toString()
        : '-';

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InnovationCompassWidget(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    label: 'Total Ideas',
                    value: totalIdeas,
                    icon: Icons.lightbulb_outline,
                    iconColor: AppColors.brandCyan,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: StatsCard(
                    label: 'Collaborator',
                    value: '17',
                    icon: Icons.group_outlined,
                    iconColor: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: StatsCard(
                    label: 'Reviews',
                    value: '4.8',
                    icon: Icons.star_outline,
                    iconColor: AppColors.brandBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Explore Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureList(context),
            const SizedBox(height: 32),
            _postIdeaButton(context),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Ideas',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    // Get all features but exclude the ones already in the main UI (Home, Idea, Collab, Profile)
    // Note: 'idea' and 'collaboration' are core, but we might want access to 'matching', 'ai', 'simulation' etc.
    final allFeatures = DashboardConfig.getAllFeatures(context);
    final features = allFeatures
        .where(
          (f) =>
              f.id != 'home' &&
              f.id != 'profile' &&
              f.id != 'idea', // ideas are listed below
        )
        .toList();

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final feature = features[index];
          return _FeatureCompactCard(
            feature: feature,
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
      // Add more cases as needed
      default:
        // For features without a specific screen yet, or handled elsewhere
        if (feature.routeName != null) {
          Navigator.pushNamed(context, feature.routeName!);
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feature ${feature.title} coming soon!'),
            duration: const Duration(seconds: 3),
          ),
        );
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
  }

  Widget _postIdeaButton(BuildContext context) {
    return StartLinkButton(
      label: 'Post New Idea',
      icon: Icons.add,
      fullWidth: true,
      onPressed: () {
        final state = context.read<ProfileBloc>().state;
        if (state is! ProfileLoaded) return;

        if (state.profile.profileCompletion >= 70) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IdeaPostScreen()),
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
    );
  }

  Widget _buildIdeaSection(BuildContext context, IdeaState state) {
    if (state is IdeaLoading) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, __) => Shimmer.fromColors(
            baseColor: AppColors.surfaceGlass,
            highlightColor: AppColors.surfaceGlass.withValues(alpha: 0.5),
            child: Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(16),
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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  MaterialPageRoute(builder: (_) => IdeaPostScreen(idea: idea)),
                );
                if (result == true && context.mounted) {
                  context.read<IdeaBloc>().add(RefreshIdeas());
                }
              },
            ),
          );
        }, childCount: state.ideas.length),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

class _FeatureCompactCard extends StatelessWidget {
  final DashboardFeature feature;
  final VoidCallback onTap;

  const _FeatureCompactCard({required this.feature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(bottom: 8), // For shadow or effect
        child: Column(
          children: [
            StartLinkGlassCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              borderGradient: LinearGradient(
                colors: [
                  AppColors.brandCyan.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: (feature.imageUrl != null && feature.imageUrl!.isNotEmpty)
                      ? Image.network(
                          feature.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Icon(
                            feature.icon,
                            color: AppColors.brandCyan,
                            size: 28,
                          ),
                        )
                      : Icon(
                          feature.icon,
                          color: AppColors.brandCyan,
                          size: 28,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              feature.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
