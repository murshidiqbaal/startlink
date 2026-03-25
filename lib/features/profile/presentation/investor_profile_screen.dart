import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_investor_profile.dart';
import 'package:startlink/features/profile/presentation/secure_resume_page.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';
import 'package:startlink/features/verification/presentation/widgets/verification_status_card.dart';

class InvestorProfileScreen extends StatefulWidget {
  final String? userId;
  const InvestorProfileScreen({super.key, this.userId});

  @override
  State<InvestorProfileScreen> createState() => _InvestorProfileScreenState();
}

class _InvestorProfileScreenState extends State<InvestorProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final userId =
        widget.userId ?? context.read<AuthRepository>().currentUser?.id;
    if (userId != null) {
      context.read<InvestorProfileBloc>().add(LoadInvestorProfile(userId));
      context.read<VerificationBloc>().add(FetchVerificationsAndBadges(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const EditInvestorProfileScreen(profileId: ''),
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
              return BlocBuilder<InvestorProfileBloc, InvestorProfileState>(
                builder: (context, roleState) {
                  if (roleState is InvestorProfileLoading ||
                      baseState is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (roleState is InvestorProfileLoaded &&
                      baseState is ProfileLoaded) {
                    if (roleState.profile.profileCompletion == 0) {
                      return _buildEmptyProfileView(context, roleState.profile.profileId);
                    }
                    return _buildBody(
                      context,
                      baseState.profile,
                      roleState.profile,
                      vState,
                    );
                  }

                  if (roleState is InvestorProfileError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppColors.rose),
                            const SizedBox(height: 16),
                            Text(
                              roleState.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: _loadProfile,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (roleState is InvestorProfileInitial ||
                      roleState is InvestorProfileSaving) {
                    if (roleState is InvestorProfileInitial) _loadProfile();
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (roleState is InvestorProfileSaved) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SecureResumePage()),
          );
        },
        label: const Text('Secure Resume'),
        icon: const Icon(Icons.fingerprint),
        backgroundColor: AppColors.brandCyan,
        foregroundColor: Colors.black,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ProfileModel baseProfile,
    InvestorProfile roleProfile,
    VerificationState vState,
  ) {
    final tickets = NumberFormat.compactCurrency(symbol: '\$');
    final badges = vState is VerificationLoaded ? vState.badges : <UserBadge>[];
    final verification = vState is VerificationLoaded ? vState.getRequestForRole('investor') : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section
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
                        roleProfile.profileCompletion >= 85
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
                            baseProfile.initials.isNotEmpty
                                ? baseProfile.initials[0]
                                : 'I',
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
                      baseProfile.fullName ?? 'Investor Name',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (roleProfile.organizationName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        roleProfile.organizationName!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    VerificationStatusCard(
                      status: badges.any((b) => b.badgeKey == 'verified_investor')
                          ? 'Approved'
                          : (verification?.status ?? 'Not Verified'),
                      role: 'investor',
                      onActionPressed: (badges.any((b) => b.badgeKey == 'verified_investor') || verification?.status == 'Pending')
                          ? null
                          : () {
                              if (roleProfile.profileCompletion < 80) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditInvestorProfileScreen(
                                      profileId: roleProfile.profileId,
                                    ),
                                  ),
                                ).then((_) => _loadProfile());
                              } else {
                                context.read<VerificationBloc>().add(
                                      RequestVerification(
                                        roleProfile.profileId,
                                        'investor',
                                        'profile_verification',
                                      ),
                                    );
                              }
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (roleProfile.bio != null) ...[
            const SizedBox(height: 24),
            Text(
              'BIO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              roleProfile.bio!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Investment Focus
          _buildCard(
            context,
            title: 'Investment Focus',
            icon: Icons.track_changes,
            child: roleProfile.investmentFocus != null
                ? Wrap(
                    spacing: 8,
                    children: roleProfile.investmentFocus!
                        .split(',')
                        .map((e) => Chip(label: Text(e.trim())))
                        .toList(),
                  )
                : const Text('Not specified'),
          ),

          const SizedBox(height: 16),

          // Stage & Ticket
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  context,
                  title: 'Preferred Stage',
                  icon: Icons.layers,
                  child: Text(
                    roleProfile.preferredStage ?? 'Any',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  context,
                  title: 'Ticket Size',
                  icon: Icons.attach_money,
                  child: Text(
                    '${tickets.format(roleProfile.ticketSizeMin ?? 0)} - ${tickets.format(roleProfile.ticketSizeMax ?? 0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Verification & Badges
          _buildCard(
            context,
            title: 'Verification & Badges',
            icon: Icons.verified_user,
            child: badges.isNotEmpty
                ? Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: badges.map((b) => _BadgeChip(badge: b)).toList(),
                  )
                : const Text(
                    'No badges earned yet.',
                    style: TextStyle(color: Colors.grey),
                  ),
          ),

          const SizedBox(height: 16),
          if (roleProfile.linkedinUrl != null)
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('LinkedIn'),
              subtitle: Text(roleProfile.linkedinUrl!),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfileView(BuildContext context, String profileId) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2), width: 2),
              ),
              child: const Icon(
                Icons.person_add_outlined,
                size: 64,
                color: AppColors.brandPurple,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Investor Profile Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create your profile to start connecting with innovators and exploring investment opportunities.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditInvestorProfileScreen(profileId: profileId),
                    ),
                  ).then((_) => _loadProfile());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Investor Profile',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  letterSpacing: 1,
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

class _BadgeChip extends StatelessWidget {
  final UserBadge badge;
  const _BadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.brandPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.3)),
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
