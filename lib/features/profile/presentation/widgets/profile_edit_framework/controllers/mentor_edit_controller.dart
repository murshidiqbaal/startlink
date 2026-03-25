// lib/features/profile/presentation/widgets/profile_edit_framework/controllers/mentor_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:startlink/features/profile/data/models/mentor_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart';

class MentorEditController extends ProfileEditController<MentorProfile> {
  final focusCtrl = TextEditingController();
  final yoeCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final certCtrl = TextEditingController();
  final expertiseInputCtrl = TextEditingController();

  List<String> expertise = [];
  List<String> certifications = [];

  @override
  void populate(ProfileModel baseProfile, MentorProfile roleProfile) {
    nameCtrl.text = baseProfile.fullName ?? '';
    aboutCtrl.text = baseProfile.about ?? '';

    focusCtrl.text = roleProfile.mentorshipFocus ?? '';
    yoeCtrl.text = roleProfile.yearsOfExperience?.toString() ?? '';
    linkedinCtrl.text = roleProfile.linkedinUrl ?? '';
    expertise = List.from(roleProfile.expertiseDomains);
    certifications = List.from(roleProfile.certifications);
  }

  @override
  MentorProfile buildRoleProfile(String profileId) {
    final focus = focusCtrl.text.trim();
    final yoe = int.tryParse(yoeCtrl.text);
    final linkedin = linkedinCtrl.text.trim();

    return MentorProfileModel(
      profileId: profileId,
      mentorshipFocus: focus,
      yearsOfExperience: yoe,
      linkedinUrl: linkedin,
      expertiseDomains: expertise,
      certifications: certifications,
      profileCompletion: MentorProfileModel.calculateCompletion(
        mentorshipFocus: focus,
        yearsOfExperience: yoe,
        linkedinUrl: linkedin,
        expertiseDomains: expertise,
      ),
    );
  }

  @override
  List<TextEditingController> get allControllers => [
        ...super.allControllers,
        focusCtrl,
        yoeCtrl,
        linkedinCtrl,
        certCtrl,
        expertiseInputCtrl,
      ];
}
