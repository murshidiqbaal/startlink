import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/collaborator_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_collaborator_profile.dart';

class CollaboratorProfileScreen extends StatelessWidget {
  final ProfileModel baseProfile;
  final bool isCurrentUser;

  const CollaboratorProfileScreen({
    super.key,
    required this.baseProfile,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => CollaboratorProfileBloc(
        repository: ctx.read<ProfileRepository>(),
      )..add(FetchCollaboratorProfile(baseProfile.id)),
      child: _CollaboratorProfileContent(
        baseProfile: baseProfile,
        isCurrentUser: isCurrentUser,
      ),
    );
  }
}

class _CollaboratorProfileContent extends StatelessWidget {
  final ProfileModel baseProfile;
  final bool isCurrentUser;

  const _CollaboratorProfileContent({
    required this.baseProfile,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<CollaboratorProfileBloc, CollaboratorProfileState>(
        builder: (context, state) {
          if (state is CollaboratorProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CollaboratorProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is CollaboratorProfileLoaded) {
            return _buildScrollableContent(context, state.profile);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context, CollaboratorProfile collabProfile) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          pinned: true,
          title: const Text('Collaborator Profile'),
          actions: isCurrentUser
              ? [
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: AppColors.brandCyan),
                    onPressed: () => _navigateToEdit(context, collabProfile),
                  ),
                ]
              : null,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroHeader(collabProfile),
                const SizedBox(height: 24),
                _buildSection(
                  title: 'Specialties',
                  icon: Icons.psychology_outlined,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: collabProfile.specialties.isEmpty
                        ? [const Text('No specialties added', style: TextStyle(color: AppColors.textSecondary))]
                        : collabProfile.specialties.map((s) => _Chip(label: s)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Availability & Rate',
                  icon: Icons.event_available_outlined,
                  child: Row(
                    children: [
                      _InfoTile(
                        label: 'Status',
                        value: collabProfile.availability ?? 'Not set',
                        icon: Icons.access_time,
                      ),
                      const SizedBox(width: 24),
                      _InfoTile(
                        label: 'Hourly Rate',
                        value: collabProfile.hourlyRate != null ? '\$${collabProfile.hourlyRate}/hr' : 'N/A',
                        icon: Icons.payments_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (collabProfile.bio?.isNotEmpty ?? false) ...[
                  _buildSection(
                    title: 'Collaborator Bio',
                    icon: Icons.description_outlined,
                    child: Text(
                      collabProfile.bio!,
                      style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _buildSection(
                  title: 'Experience',
                  icon: Icons.work_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${collabProfile.experienceYears ?? 0} Years of Experience',
                        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text('Preferred Projects:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: collabProfile.preferredProjectTypes.isEmpty
                            ? [const Text('Any', style: TextStyle(color: AppColors.textSecondary))]
                            : collabProfile.preferredProjectTypes.map((p) => _Chip(label: p, color: AppColors.brandCyan)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: 'Links & Resources',
                  icon: Icons.link,
                  child: Column(
                    children: [
                      if (collabProfile.portfolioUrl?.isNotEmpty ?? false)
                        _LinkRow(icon: Icons.language, label: 'Portfolio', url: collabProfile.portfolioUrl!),
                      if (collabProfile.githubUrl?.isNotEmpty ?? false)
                        _LinkRow(icon: Icons.code, label: 'GitHub', url: collabProfile.githubUrl!),
                      if (collabProfile.linkedinUrl?.isNotEmpty ?? false)
                        _LinkRow(icon: Icons.link, label: 'LinkedIn', url: collabProfile.linkedinUrl!),
                      if (collabProfile.resumeUrl?.isNotEmpty ?? false)
                        _LinkRow(icon: Icons.description, label: 'Resume', url: collabProfile.resumeUrl!),
                      if ((collabProfile.portfolioUrl?.isEmpty ?? true) &&
                          (collabProfile.githubUrl?.isEmpty ?? true) &&
                          (collabProfile.linkedinUrl?.isEmpty ?? true) &&
                          (collabProfile.resumeUrl?.isEmpty ?? true))
                        const Text('No links added', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                if (isCurrentUser)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _navigateToEdit(context, collabProfile),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Update Collaborator Details'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroHeader(CollaboratorProfile profile) {
    final completion = profile.profileCompletion;
    final color = completion < 40 ? AppColors.rose : (completion < 70 ? AppColors.amber : AppColors.emerald);

    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: baseProfile.avatarUrl != null ? NetworkImage(baseProfile.avatarUrl!) : null,
              child: baseProfile.avatarUrl == null ? Text(baseProfile.initials, style: const TextStyle(fontSize: 24)) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baseProfile.fullName ?? 'Anonymous Collaborator',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    baseProfile.headline ?? 'Ready to collaborate',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Profile Strength', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  Text('$completion%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: completion / 100,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.brandCyan),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
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

  void _navigateToEdit(BuildContext context, CollaboratorProfile profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CollaboratorProfileBloc>(),
          child: EditCollaboratorProfileScreen(profile: profile),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<CollaboratorProfileBloc>().add(FetchCollaboratorProfile(baseProfile.id));
      }
    });
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  const _LinkRow({required this.icon, required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.brandCyan),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Flexible(
            child: Text(
              url.replaceAll('https://', '').replaceAll('http://', ''),
              style: const TextStyle(
                color: AppColors.brandCyan,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, this.color = AppColors.brandPurple});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.brandCyan),
            const SizedBox(width: 4),
            Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}
