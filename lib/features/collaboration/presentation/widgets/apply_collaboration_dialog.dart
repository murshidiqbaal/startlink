import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String _selectedRole = 'Developer'; // Default or make dynamic
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
            'Please enter a message explaining why you want to join.',
          ),
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Apply to ${widget.idea.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Role:'),
            Wrap(
              spacing: 8.0,
              children: _roles.map((role) {
                return ChoiceChip(
                  label: Text(role),
                  selected: _selectedRole == role,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedRole = role;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Why do you want to collaborate?',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              maxLength: 300,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('Apply')),
      ],
    );
  }
}
