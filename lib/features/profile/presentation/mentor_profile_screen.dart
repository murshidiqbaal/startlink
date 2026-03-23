import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_mentor_profile.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';

class MentorProfileScreen extends StatefulWidget {
  final String? userId;

  const MentorProfileScreen({super.key, this.userId});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final userId =
        widget.userId ?? context.read<AuthRepository>().currentUser?.id;
    if (userId != null) {
      context.read<MentorProfileBloc>().add(LoadMentorProfile(userId));
      context.read<VerificationBloc>().add(FetchVerificationsAndBadges(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditMentorProfileScreen(profileId: ''),
                ),
              ).then((_) => _loadProfile());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, baseState) {
          return BlocBuilder<VerificationBloc, VerificationState>(
            builder: (context, vState) {
              return BlocBuilder<MentorProfileBloc, MentorProfileState>(
                builder: (context, roleState) {
                  if (roleState is MentorProfileLoading ||
                      baseState is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (roleState is MentorProfileLoaded &&
                      baseState is ProfileLoaded) {
                    return _buildBody(
                      context,
                      baseState.profile,
                      roleState.profile,
                      vState,
                    );
                  }

                  if (roleState is MentorProfileError) {
                    return Center(child: Text(roleState.message));
                  }

                  if (roleState is MentorProfileInitial) {
                    _loadProfile();
                    return const Center(child: CircularProgressIndicator());
                  }

                  return const Center(child: CircularProgressIndicator());
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic baseProfile,
    MentorProfile roleProfile,
    VerificationState vState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: roleProfile.profileCompletion / 100,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        roleProfile.profileCompletion >= 80
                            ? AppColors.emerald
                            : AppColors.amber,
                      ),
                      strokeWidth: 5,
                    ),
                  ),
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: baseProfile.avatarUrl != null
                        ? NetworkImage(baseProfile.avatarUrl!)
                        : null,
                    child: baseProfile.avatarUrl == null
                        ? Text(
                            baseProfile.fullName?.substring(0, 1) ?? 'M',
                            style: const TextStyle(fontSize: 24),
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
                      baseProfile.fullName ?? 'Mentor Name',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildVerificationRow(vState),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.work_outline,
                          size: 16,
                          color: AppColors.brandCyan,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${roleProfile.yearsOfExperience ?? 0} Years Exp.',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (roleProfile.profileCompletion < 80)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const EditMentorProfileScreen(profileId: ''),
                    ),
                  ).then((_) => _loadProfile());
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('Complete Profile to be Listed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                ),
              ),
            ),

          if (roleProfile.profileCompletion < 80) const SizedBox(height: 24),

          _buildSectionHeader(context, 'About & Focus'),
          Text(
            roleProfile.mentorshipFocus ?? 'Add your mentorship focus...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Expertise'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roleProfile.expertiseDomains
                .map(
                  (e) => Chip(
                    label: Text(e),
                    backgroundColor: AppColors.surfaceGlass,
                    side: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                )
                .toList(),
          ),
          if (roleProfile.expertiseDomains.isEmpty)
            const Text(
              'No expertise listed',
              style: TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 32),

          _buildSectionHeader(context, 'Badges & Recognition'),
          const SizedBox(height: 8),
          if (vState is VerificationLoaded && vState.badges.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vState.badges.map((b) => _BadgeChip(badge: b)).toList(),
            )
          else
            const Text(
              'No badges earned yet.',
              style: TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Credentials'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link, color: AppColors.brandBlue),
            title: const Text('LinkedIn Profile'),
            subtitle: Text(roleProfile.linkedinUrl ?? 'Not linked'),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(VerificationState state) {
    bool isVerified = false;
    String statusStr = 'Not Verified';
    Color color = AppColors.rose;

    if (state is VerificationLoaded) {
      if (state.isRoleVerified('mentor')) {
        isVerified = true;
        statusStr = 'Verified Mentor';
        color = AppColors.emerald;
      } else {
        final req = state.getRequestForRole('mentor');
        if (req != null) {
          statusStr = req.status;
          color = req.status == 'Pending' ? AppColors.amber : AppColors.rose;
        }
      }
    }

    return Row(
      children: [
        Icon(
          isVerified ? Icons.verified : Icons.error_outline,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          statusStr,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.brandPurple,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final UserBadge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPurple.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.military_tech,
            size: 14,
            color: AppColors.brandPurple,
          ),
          const SizedBox(width: 4),
          Text(
            badge.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
