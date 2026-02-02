import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/edit_investor_profile.dart';

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
                  builder: (_) => const EditInvestorProfileScreen(),
                ),
              ).then((_) => _loadProfile());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, baseState) {
          return BlocBuilder<InvestorProfileBloc, InvestorProfileState>(
            builder: (context, roleState) {
              if (roleState is InvestorProfileLoading ||
                  baseState is ProfileLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (roleState is InvestorProfileLoaded &&
                  baseState is ProfileLoaded) {
                return _buildBody(
                  context,
                  baseState.profile,
                  roleState.profile,
                );
              }

              if (roleState is InvestorProfileError) {
                return Center(child: Text(roleState.message));
              }

              if (roleState is InvestorProfileInitial) {
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
    ProfileModel baseProfile,
    InvestorProfile roleProfile,
  ) {
    final tickets = NumberFormat.compactCurrency(symbol: '\$');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Photo & Completion
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
                            baseProfile.fullName?.substring(0, 1) ?? 'I',
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
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Accredited Investor', // Placeholder or derivation
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

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

          // Validation
          _buildCard(
            context,
            title: 'Verification Status',
            icon: Icons.shield,
            child: Row(
              children: [
                Icon(
                  roleProfile.isVerified ? Icons.check_circle : Icons.pending,
                  color: roleProfile.isVerified ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  roleProfile.isVerified
                      ? 'Identity Verified'
                      : 'Pending Verification',
                ),
              ],
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
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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
