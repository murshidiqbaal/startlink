import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/core/presentation/widgets/startlink_button.dart';

class ApplyCollaborationDialog extends StatefulWidget {
  final String ideaId;
  final String innovatorId;

  const ApplyCollaborationDialog({
    super.key,
    required this.ideaId,
    required this.innovatorId,
  });

  @override
  State<ApplyCollaborationDialog> createState() => _ApplyCollaborationDialogState();
}

class _ApplyCollaborationDialogState extends State<ApplyCollaborationDialog> {
  final _roleController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _roleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    final role = _roleController.text.trim();
    final message = _messageController.text.trim();

    if (role.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    context.read<CollaborationBloc>().add(
      ApplyCollaboration(
        ideaId: widget.ideaId,
        innovatorId: widget.innovatorId,
        roleApplied: role,
        message: message,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CollaborationBloc, CollaborationState>(
      listener: (context, state) {
        if (state is CollaborationApplied) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is CollaborationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CollaborationLoading;

        return AlertDialog(
          backgroundColor: AppColors.surfaceGlass,
          title: Text(
            'Apply to Collaborate',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Role Applied For (e.g., Developer)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandPurple),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _messageController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Your Message',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.brandPurple),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            StartLinkButton(
              label: isLoading ? 'Applying...' : 'Apply',
              onPressed: isLoading ? null : _submitApplication,
            ),
          ],
        );
      },
    );
  }
}
