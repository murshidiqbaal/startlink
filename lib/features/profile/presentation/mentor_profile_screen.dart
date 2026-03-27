import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_state.dart';
import 'package:startlink/features/profile/presentation/edit_mentor_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';
import 'package:startlink/features/profile/presentation/widgets/verification_status_card.dart';
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
      context.read<VerificationBloc>().add(
        CheckVerificationStatus(userId, 'mentor'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Mentor Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              final userId =
                  widget.userId ??
                  context.read<AuthRepository>().currentUser?.id;
              if (userId == null) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMentorProfileScreen(profileId: userId),
                ),
              ).then((_) => _loadProfile());
            },
          ),
        ],
      ),
      body: BlocBuilder<VerificationBloc, VerificationState>(
        builder: (context, vState) {
          return BlocBuilder<MentorProfileBloc, MentorProfileState>(
            builder: (context, state) {
              if (state is MentorProfileLoading || state is MentorProfileInitial) {
                return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
              }

              if (state is MentorProfileError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.rose),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is MentorProfileLoaded) {
                final isSelf = widget.userId == null || widget.userId == context.read<AuthRepository>().currentUser?.id;
                
                // Show empty view only if it's the user's own profile and it's not started
                if (isSelf && state.profile.profileCompletion == 0 && (state.profile.bio == null || state.profile.bio!.isEmpty)) {
                  return _buildEmptyProfileView(context, state.profile.profileId);
                }

                return _buildBody(
                  context,
                  state.baseProfile,
                  state.profile,
                  _mapStatus(state.verification?.status),
                  vState,
                );
              }

              return const Center(child: CircularProgressIndicator());
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
    VerificationStatus verificationStatus,
    VerificationState vState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, baseProfile, roleProfile, verificationStatus),
          const SizedBox(height: 32),
          
          if (roleProfile.bio != null && roleProfile.bio!.isNotEmpty) ...[
            _buildSectionHeader(context, 'About & Focus'),
            Text(
              roleProfile.bio!,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
          ],

          if (roleProfile.expertise.isNotEmpty) ...[
            _buildSectionHeader(context, 'Expertise'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: roleProfile.expertise
                  .map((e) => _ExpertiseChip(label: e))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (roleProfile.availability != null && roleProfile.availability!.isNotEmpty) ...[
            _buildSectionHeader(context, 'Availability'),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.brandCyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      roleProfile.availability!,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          _buildSectionHeader(context, 'Credentials & Badges'),
          if (vState is VerificationApproved && vState.badges.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: vState.badges.map((b) => _BadgeChip(badge: b)).toList(),
            )
          else if (verificationStatus == VerificationStatus.verified)
             const _BadgeChip(badgeName: 'Verified Mentor')
          else
            const Text(
              'Profile pending full verification.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontStyle: FontStyle.italic),
            ),

          const SizedBox(height: 24),
          _buildInfoRow(Icons.link, 'LinkedIn Profile', roleProfile.linkedinUrl ?? 'Not linked'),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    dynamic baseProfile,
    MentorProfile roleProfile,
    VerificationStatus verificationStatus,
  ) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: CircularProgressIndicator(
                value: roleProfile.profileCompletion / 100,
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                valueColor: AlwaysStoppedAnimation<Color>(
                  roleProfile.profileCompletion >= 80 ? AppColors.emerald : AppColors.amber,
                ),
                strokeWidth: 6,
              ),
            ),
            CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.surfaceGlass,
              backgroundImage: baseProfile.avatarUrl != null ? NetworkImage(baseProfile.avatarUrl!) : null,
              child: baseProfile.avatarUrl == null
                ? Text(baseProfile.initials.isNotEmpty ? baseProfile.initials[0] : '?', 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))
                : null,
            ),
          ],
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baseProfile.fullName ?? 'Unnamed Mentor',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.history_edu, size: 16, color: AppColors.brandPurple),
                  const SizedBox(width: 6),
                  Text(
                    '${roleProfile.yearsExperience ?? 0} Years Experience',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              VerificationStatusCard(
                status: verificationStatus,
                role: 'mentor',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.brandPurple,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.brandBlue),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfileView(BuildContext context, String profileId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 80, color: AppColors.brandPurple.withValues(alpha: 0.5)),
            const SizedBox(height: 24),
            const Text(
              'Complete Your Mentor Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add your expertise and availability to start helping innovators reach their potential.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EditMentorProfileScreen(profileId: profileId)),
                  ).then((_) => _loadProfile());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Start Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  VerificationStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'verified': return VerificationStatus.verified;
      case 'pending': return VerificationStatus.pending;
      case 'rejected': return VerificationStatus.rejected;
      default: return VerificationStatus.notVerified;
    }
  }
}

class _ExpertiseChip extends StatelessWidget {
  final String label;
  const _ExpertiseChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final UserBadge? badge;
  final String? badgeName;
  const _BadgeChip({this.badge, this.badgeName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified_user, size: 16, color: AppColors.emerald),
          const SizedBox(width: 8),
          Text(
            badge?.name ?? badgeName ?? 'Verified',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
