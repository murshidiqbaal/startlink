import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/presentation/widgets/space_0/aura_overlay.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/collaboration/presentation/bloc/collaboration_bloc.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';

class ApplyCollaborationDialog extends StatefulWidget {
  final Idea idea;

  const ApplyCollaborationDialog({super.key, required this.idea});

  @override
  State<ApplyCollaborationDialog> createState() =>
      _ApplyCollaborationDialogState();
}

class _ApplyCollaborationDialogState extends State<ApplyCollaborationDialog> {
  final _messageController = TextEditingController();
  String _selectedRole = 'Developer';
  final List<String> _roles = [
    'Developer',
    'Designer',
    'Marketer',
    'Product Manager',
    'Other',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Keep it professional. Explain why you are the best fit!',
          ),
          backgroundColor: AppColors.rose,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<CollaborationBloc>().add(
      ApplyCollaboration(
        ideaId: widget.idea.id,
        innovatorId: widget.idea.ownerId,
        roleApplied: _selectedRole,
        message: _messageController.text.trim(),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CollaborationBloc, CollaborationState>(
      listener: (context, state) {
        if (state is CollaborationApplied) {
          AuraOverlay.show(context, state.message);
          Navigator.of(context).pop();
        } else if (state is CollaborationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.rose,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CollaborationLoading;

        return AlertDialog(
          backgroundColor: AppColors.surfaceGlass,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: Text(
            'Apply to ${widget.idea.title}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select your role:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _roles.map((role) {
                    final isSelected = _selectedRole == role;
                    return ChoiceChip(
                      label: Text(
                        role,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: isLoading
                          ? null
                          : (selected) {
                              if (selected) {
                                setState(() => _selectedRole = role);
                              }
                            },
                      selectedColor: AppColors.brandPurple,
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.brandPurple
                              : Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _messageController,
                  enabled: !isLoading,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Pitch yourself',
                    hintText: 'I would love to join because...',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withValues(alpha: 0.4),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  maxLines: 4,
                  maxLength: 300,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 100,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Apply',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
