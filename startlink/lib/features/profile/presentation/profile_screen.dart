import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
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
                  const SnackBar(content: Text('Wait for profile to load')),
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
        ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Header Section
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
                          profile.fullName?.substring(0, 1).toUpperCase() ??
                              'U',
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
          Text(
            '${profile.profileCompletion}% Complete',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getCompletionColor(profile.profileCompletion),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profile.fullName ?? 'No Name',
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
          // Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.linkedinUrl != null &&
                  profile.linkedinUrl!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.link),
                ), // Placeholder for icons
              if (profile.githubUrl != null && profile.githubUrl!.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.code),
                ),
            ],
          ),
        ],
      ),
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
