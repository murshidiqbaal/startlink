import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/bloc/auth_bloc.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/verification/presentation/bloc/verification_bloc.dart';

class VerificationPendingScreen extends StatelessWidget {
  final UserVerification? verification;

  const VerificationPendingScreen({super.key, this.verification});

  @override
  Widget build(BuildContext context) {
    final isRejected = verification?.status == 'Rejected';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.logout, color: AppColors.textPrimary),
          onPressed: () => context.read<AuthBloc>().add(AuthLogoutRequested()),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: (isRejected ? AppColors.rose : AppColors.brandPurple).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isRejected ? Icons.error_outline : Icons.verified_user_outlined,
                  size: 72,
                  color: isRejected ? AppColors.rose : AppColors.brandPurple,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isRejected ? 'Verification Rejected' : 'Verification in Progress',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                isRejected
                    ? 'Our team has reviewed and rejected your request. Please check the reason below and re-submit your profile.'
                    : 'Your startup credentials are being reviewed by the Startlink team. This usually takes 24-48 hours.',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              if (isRejected && verification != null) ...[
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.rose.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'REASON',
                        style: TextStyle(
                          color: AppColors.rose,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Reason not specified', // Actual reason retrieval logic needed if metadata updated
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final userId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;
                    context.read<VerificationBloc>().add(FetchVerificationsAndBadges(userId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Refresh Status'),
                ),
              ),
              if (isRejected) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Logic to let them edit profile again?
                    // For now, refreshing is fine if they updated something
                  },
                  child: const Text('Update Profile', style: TextStyle(color: AppColors.brandCyan)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
