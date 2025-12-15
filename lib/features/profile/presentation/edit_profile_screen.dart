import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/presentation/bloc/profile_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileModel profile;
  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _headlineController;
  late TextEditingController _aboutController;
  late TextEditingController _skillsController;
  late TextEditingController _educationController;
  late TextEditingController _portfolioController;
  late TextEditingController _linkedinController;
  late TextEditingController _githubController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _headlineController = TextEditingController(text: widget.profile.headline);
    _aboutController = TextEditingController(text: widget.profile.about);
    _skillsController = TextEditingController(
      text: widget.profile.skills.join(', '),
    );
    _educationController = TextEditingController(
      text: widget.profile.education,
    );
    _portfolioController = TextEditingController(
      text: widget.profile.portfolioUrl,
    );
    _linkedinController = TextEditingController(
      text: widget.profile.linkedinUrl,
    );
    _githubController = TextEditingController(text: widget.profile.githubUrl);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _headlineController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _portfolioController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (mounted) {
        context.read<ProfileBloc>().add(UploadAvatar(File(image.path)));
      }
    }
  }

  void _saveProfile() {
    final updatedProfile = widget.profile.copyWith(
      fullName: _fullNameController.text,
      headline: _headlineController.text,
      about: _aboutController.text,
      skills: _skillsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      education: _educationController.text,
      portfolioUrl: _portfolioController.text,
      linkedinUrl: _linkedinController.text,
      githubUrl: _githubController.text,
    );

    context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            TextButton(onPressed: _saveProfile, child: const Text('Save')),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, state) {
                        final currentAvatarUrl = (state is ProfileLoaded)
                            ? state.profile.avatarUrl
                            : widget.profile.avatarUrl;
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage:
                              currentAvatarUrl != null &&
                                  currentAvatarUrl.isNotEmpty
                              ? NetworkImage(currentAvatarUrl)
                              : null,
                          child:
                              currentAvatarUrl == null ||
                                  currentAvatarUrl.isEmpty
                              ? Text(
                                  widget.profile.fullName
                                          ?.substring(0, 1)
                                          .toUpperCase() ??
                                      'U',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          child: Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Full Name', _fullNameController),
              _buildTextField('Headline', _headlineController),
              _buildTextField('About', _aboutController, maxLines: 4),
              _buildTextField('Skills (comma separated)', _skillsController),
              _buildTextField('Education', _educationController),
              const Divider(),
              _buildTextField('Portfolio URL', _portfolioController),
              _buildTextField('LinkedIn URL', _linkedinController),
              _buildTextField('GitHub URL', _githubController),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
