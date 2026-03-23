import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_bloc.dart';

class EditCollaboratorProfileScreen extends StatefulWidget {
  final CollaboratorProfile profile;

  const EditCollaboratorProfileScreen({super.key, required this.profile});

  @override
  State<EditCollaboratorProfileScreen> createState() =>
      _EditCollaboratorProfileScreenState();
}

class _EditCollaboratorProfileScreenState
    extends State<EditCollaboratorProfileScreen> {
  late TextEditingController _bioController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _experienceController;
  late List<String> _specialties;
  late List<String> _preferredProjects;
  String? _availability;

  final List<String> _availabilityOptions = [
    'Full-time',
    'Part-time',
    'Freelance',
    'Weekends only',
  ];

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: widget.profile.bio);
    _hourlyRateController = TextEditingController(
      text: widget.profile.hourlyRate?.toString() ?? '',
    );
    _experienceController = TextEditingController(
      text: widget.profile.experienceYears?.toString() ?? '',
    );
    _specialties = List.from(widget.profile.specialties);
    _preferredProjects = List.from(widget.profile.preferredProjectTypes);
    _availability = widget.profile.availability;
  }

  @override
  void dispose() {
    _bioController.dispose();
    _hourlyRateController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _save() {
    final updatedProfile = CollaboratorProfileModel(
      profileId: widget.profile.profileId,
      bio: _bioController.text,
      hourlyRate: double.tryParse(_hourlyRateController.text),
      experienceYears: int.tryParse(_experienceController.text),
      specialties: List.from(_specialties),
      preferredProjectTypes: List.from(_preferredProjects),
      availability: _availability,
      profileCompletion: widget.profile.profileCompletion,
    );

    context.read<CollaboratorProfileBloc>().add(
      UpdateCollaboratorProfile(updatedProfile),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollaboratorProfileBloc, CollaboratorProfileState>(
      listener: (context, state) {
        if (state is CollaboratorProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        }
        if (state is CollaboratorProfileError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Edit Collaborator Profile'),
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: AppColors.brandCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Bio', _bioController, maxLines: 4),
              const SizedBox(height: 20),
              _buildDropdown(
                'Availability',
                _availability,
                _availabilityOptions,
                (val) => setState(() => _availability = val),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Years of Experience',
                      _experienceController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Hourly Rate (\$)',
                      _hourlyRateController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildMultiSelect('Specialties', _specialties, [
                'UI/UX',
                'Frontend',
                'Backend',
                'Mobile',
                'AI/ML',
                'Marketing',
                'Sales',
              ]),
              const SizedBox(height: 20),
              _buildMultiSelect('Project Types', _preferredProjects, [
                'Web Apps',
                'Mobile Apps',
                'SaaS',
                'Fintech',
                'EdTech',
                'Open Source',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceGlass,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> options,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: AppColors.background,
              items: options
                  .map(
                    (o) => DropdownMenuItem(
                      value: o,
                      child: Text(
                        o,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelect(
    String label,
    List<String> selected,
    List<String> options,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  if (val)
                    selected.add(option);
                  else
                    selected.remove(option);
                });
              },
              backgroundColor: AppColors.surfaceGlass,
              selectedColor: AppColors.brandPurple.withOpacity(0.5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
