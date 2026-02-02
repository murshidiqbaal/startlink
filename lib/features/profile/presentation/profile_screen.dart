import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/achievements/presentation/bloc/achievement_bloc.dart';
import 'package:startlink/features/achievements/presentation/widgets/achievement_badge.dart';
import 'package:startlink/features/aura/presentation/bloc/aura_bloc.dart';
import 'package:startlink/features/aura/presentation/widgets/aura_badge.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_profile_screen.dart';
import 'package:startlink/features/trust/presentation/bloc/trust_score_bloc.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:startlink/features/verification/presentation/widgets/verification_badge_row.dart';
import 'package:startlink/features/verification/presentation/widgets/verification_status_chip.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId; // If null, shows current user's profile
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    if (userId != null) {
      // Viewing another user's profile
      return BlocProvider(
        create: (context) =>
            ProfileBloc(profileRepository: context.read<ProfileRepository>())
              ..add(FetchProfileById(userId!)),
        child: const _ProfileScaffold(isCurrentUser: false),
      );
    }
    // Viewing my own profile
    return const _ProfileScaffold(isCurrentUser: true);
  }
}

class _ProfileScaffold extends StatelessWidget {
  final bool isCurrentUser;
  const _ProfileScaffold({required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? 'My Profile' : 'Profile'),
        actions: isCurrentUser
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    final state = context.read<ProfileBloc>().state;
                    if (state is ProfileLoaded) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProfileScreen(profile: state.profile),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wait for profile to load'),
                        ),
                      );
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    context.read<AuthBloc>().add(AuthLogoutRequested());
                  },
                ),
              ]
            : null,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileModel profile) {
    if (isCurrentUser) {
      return RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(FetchProfile());
          context.read<VerificationBloc>().add(
            FetchVerificationsAndBadges(profile.id),
          );
          context.read<AuraBloc>().add(FetchAura(profile.id));
          context.read<AchievementBloc>().add(FetchAchievements(profile.id));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: _buildProfileDetails(context, profile),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Trigger verification fetch for viewed profile
          Builder(
            builder: (context) {
              context.read<VerificationBloc>().add(
                FetchVerificationsAndBadges(profile.id),
              );
              // Trigger Aura Fetch
              context.read<AuraBloc>().add(FetchAura(profile.id));
              // Trigger Achievement Fetch
              context.read<AchievementBloc>().add(
                FetchAchievements(profile.id),
              );
              return const SizedBox.shrink();
            },
          ),
          _buildProfileDetails(context, profile),
        ],
      ),
    );
  }

  Widget _buildProfileDetails(BuildContext context, ProfileModel profile) {
    return Column(
      children: [
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: profile.profileCompletion / 100,
                  strokeWidth: 6,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getCompletionColor(profile.profileCompletion),
                  ),
                ),
              ),
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage:
                    profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null || profile.avatarUrl!.isEmpty
                    ? Text(
                        profile.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Verification & Badges Section
        BlocBuilder<TrustScoreBloc, TrustScoreState>(
          builder: (context, trustState) {
            int score = 0;
            if (trustState is TrustScoreLoaded) score = trustState.score;

            return Column(
              children: [
                if (score > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Text(
                      'Trust Score: $score',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                BlocBuilder<VerificationBloc, VerificationState>(
                  builder: (context, state) {
                    if (state is VerificationLoaded) {
                      return Column(
                        children: [
                          VerificationStatusChip(
                            isVerified: state.isProfileVerified,
                            label: 'Profile Verified',
                          ),
                          const SizedBox(height: 8),
                          if (state.badges.isNotEmpty)
                            VerificationBadgeRow(badges: state.badges),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        // Aura Points Badge
        BlocBuilder<AuraBloc, AuraState>(
          builder: (context, state) {
            if (state is AuraLoading) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: SizedBox(
                  width: 80,
                  height: 32,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            if (state is AuraLoaded) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AuraBadge(
                  points: state.totalPoints,
                  showLabel: true,
                  animate: true,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        Text(
          profile.fullName ?? 'User',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (profile.headline != null) ...[
          const SizedBox(height: 8),
          Text(
            profile.headline!,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
        const SizedBox(height: 24),

        // Achievements Section
        BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is AchievementLoaded && state.achievements.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievements 🏆',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.achievements.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return AchievementBadge(
                          achievement: state.achievements[index],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Activity/Ideas Lists
        if (profile.role == 'Innovator') ...[
          _buildSkillsSection(context, profile.skills),
          const SizedBox(height: 16),
        ],
        _buildInfoSection(context, 'About', profile.about),
        const SizedBox(height: 16),
        if (profile.skills.isNotEmpty) ...[
          _buildSkillsSection(context, profile.skills),
          const SizedBox(height: 16),
        ],
        _buildInfoSection(context, 'Education', profile.education),
        const SizedBox(height: 16),
        _buildInfoSection(context, 'Experience', profile.experienceLevel),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (profile.linkedinUrl != null && profile.linkedinUrl!.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.link),
              ),
            if (profile.githubUrl != null && profile.githubUrl!.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.code),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String? content,
  ) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, List<String> skills) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills.map((skill) => Chip(label: Text(skill))).toList(),
          ),
        ],
      ),
    );
  }

  Color _getCompletionColor(int percentage) {
    if (percentage < 40) return Colors.red;
    if (percentage < 70) return Colors.orange;
    return Colors.green;
  }
}
