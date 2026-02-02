import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/mentor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_mentor_profile.dart';

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
                  builder: (_) => const EditMentorProfileScreen(),
                ),
              ).then((_) => _loadProfile());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, baseState) {
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
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic baseProfile,
    MentorProfile roleProfile,
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
                            ? Colors.green
                            : Colors.orange,
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
                    Text(
                      baseProfile.headline ?? 'No Headline',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${roleProfile.yearsOfExperience ?? 0} Years Exp.',
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
                      builder: (_) => const EditMentorProfileScreen(),
                    ),
                  ).then((_) => _loadProfile());
                },
                icon: const Icon(Icons.warning_amber_rounded),
                label: const Text('Complete Profile to be Listed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[900],
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                  ),
                )
                .toList(),
          ),
          if (roleProfile.expertiseDomains.isEmpty)
            const Text(
              'No expertise listed',
              style: TextStyle(color: Colors.grey),
            ),

          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Credentials'),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.link, color: Colors.blue),
            title: const Text('LinkedIn Profile'),
            subtitle: Text(roleProfile.linkedinUrl ?? 'Not linked'),
            onTap: roleProfile.linkedinUrl != null
                ? () {
                    // Open URL
                  }
                : null,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              roleProfile.isVerified ? Icons.verified : Icons.verified_outlined,
              color: roleProfile.isVerified ? Colors.blue : Colors.grey,
            ),
            title: Text(
              roleProfile.isVerified
                  ? 'Verified Mentor'
                  : 'Verification Pending',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
