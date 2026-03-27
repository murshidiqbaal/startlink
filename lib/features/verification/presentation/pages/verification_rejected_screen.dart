import 'package:flutter/material.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/profile/presentation/widgets/verification_status_card.dart';

class VerificationRejectedScreen extends StatelessWidget {
  final UserVerification verification;

  const VerificationRejectedScreen({
    super.key,
    required this.verification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VerificationStatusCard(
              status: VerificationStatus.rejected,
              role: verification.role,
              customSubtitle: verification.rejectionReason ?? 
                  'Your profile verification was not approved. Please review the details and try again.',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Navigate back to edit profile
                Navigator.of(context).pop();
              },
              child: const Text('Update Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
