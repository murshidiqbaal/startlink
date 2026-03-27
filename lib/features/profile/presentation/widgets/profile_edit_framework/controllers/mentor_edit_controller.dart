// lib/features/profile/presentation/widgets/profile_edit_framework/controllers/mentor_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart';

class MentorEditController extends ProfileEditController<MentorProfile> {
  final bioCtrl = TextEditingController(); // Replaces focusCtrl
  final yoeCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final availabilityCtrl = TextEditingController(); // New field
  final expertiseInputCtrl = TextEditingController();

  List<String> expertise = [];

  @override
  void populate(ProfileModel baseProfile, MentorProfile roleProfile) {
    nameCtrl.text = baseProfile.fullName ?? '';
    aboutCtrl.text = baseProfile.about ?? '';

    bioCtrl.text = roleProfile.bio ?? '';
    yoeCtrl.text = roleProfile.yearsExperience?.toString() ?? '';
    linkedinCtrl.text = roleProfile.linkedinUrl ?? '';
    availabilityCtrl.text = roleProfile.availability ?? '';
    expertise = List.from(roleProfile.expertise);
  }

  @override
  MentorProfile buildRoleProfile(String profileId) {
    final bio = bioCtrl.text.trim();
    final yoe = int.tryParse(yoeCtrl.text);
    final linkedin = linkedinCtrl.text.trim();
    final availability = availabilityCtrl.text.trim();

    final completion = MentorProfileModel.calculateCompletion(
      expertise: expertise,
      yearsExperience: yoe,
      bio: bio,
      linkedinUrl: linkedin,
      availability: availability,
    );

    return MentorProfileModel(
      profileId: profileId,
      bio: bio,
      yearsExperience: yoe,
      linkedinUrl: linkedin,
      expertise: expertise,
      availability: availability,
      profileCompletion: completion,
    );
  }

  @override
  List<TextEditingController> get allControllers => [
        ...super.allControllers,
        bioCtrl,
        yoeCtrl,
        linkedinCtrl,
        availabilityCtrl,
        expertiseInputCtrl,
      ];
}
