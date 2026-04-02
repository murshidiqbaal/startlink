// lib/features/profile/presentation/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_state.dart';
import 'package:startlink/features/profile/presentation/collaborator_profile_screen.dart';
import 'package:startlink/features/profile/presentation/innovator_profile_screen.dart';
import 'package:startlink/features/profile/presentation/investor_profile_screen.dart';
import 'package:startlink/features/profile/presentation/mentor_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String? userId; // profiles.id of ANOTHER user (null = current user)
  const ProfileScreen({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    // Shared ProfileBloc is provided by AppShell
    return _ProfileDispatcher(
      userId: userId,
      isCurrentUser: userId == null,
    );
  }
}

class _ProfileDispatcher extends StatelessWidget {
  final String? userId;
  final bool isCurrentUser;

  const _ProfileDispatcher({this.userId, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (ctx, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: AppColors.rose),
              ),
            );
          }
          if (state is ProfileLoaded) {
            final role = state.profile.role?.toLowerCase() ?? 'innovator';

            switch (role) {
              case 'collaborator':
                return CollaboratorProfileScreen(
                  baseProfile: state.profile,
                  isCurrentUser: isCurrentUser,
                );
              case 'investor':
                return InvestorProfileScreen(userId: userId);
              case 'mentor':
                return MentorProfileScreen(userId: userId);
              case 'innovator':
              default:
                return InnovatorProfileScreen(
                  profile: state.profile,
                  isCurrentUser: isCurrentUser,
                );
            }
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        },
      ),
    );
  }
}
