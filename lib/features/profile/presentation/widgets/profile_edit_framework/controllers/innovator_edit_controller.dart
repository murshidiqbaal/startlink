// lib/features/profile/presentation/widgets/profile_edit_framework/controllers/innovator_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:startlink/features/profile/data/models/innovator_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart';

class InnovatorEditController extends ProfileEditController<InnovatorProfile> {
  final startupNameCtrl = TextEditingController();
  final educationCtrl = TextEditingController();
  final portfolioUrlCtrl = TextEditingController();
  final githubUrlCtrl = TextEditingController();
  final linkedinUrlCtrl = TextEditingController();
  final resumeUrlCtrl = TextEditingController();
  final twitterUrlCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final skillInputCtrl = TextEditingController();

  List<String> skills = [];
  String? experienceLevel;
  String? currentStatus;
  String? preferredWorkMode;
  bool buildingStartup = false;
  bool openToCofounder = false;
  bool openToInvestors = false;
  bool openToMentors = false;

  @override
  void populate(ProfileModel baseProfile, InnovatorProfile roleProfile) {
    nameCtrl.text = baseProfile.fullName ?? '';
    aboutCtrl.text = baseProfile.about ?? '';

    bioCtrl.text = roleProfile.bio ?? '';
    startupNameCtrl.text = roleProfile.startupName ?? '';
    educationCtrl.text = roleProfile.education ?? '';
    portfolioUrlCtrl.text = roleProfile.portfolioUrl ?? '';
    githubUrlCtrl.text = roleProfile.githubUrl ?? '';
    linkedinUrlCtrl.text = roleProfile.linkedinUrl ?? '';
    resumeUrlCtrl.text = roleProfile.resumeUrl ?? '';
    twitterUrlCtrl.text = roleProfile.twitterUrl ?? '';
    skills = List.from(roleProfile.skills);
    experienceLevel = roleProfile.experienceLevel;
    currentStatus = roleProfile.currentStatus;
    preferredWorkMode = roleProfile.preferredWorkMode;
    buildingStartup = roleProfile.buildingStartup;
    openToCofounder = roleProfile.openToCofounder;
    openToInvestors = roleProfile.openToInvestors;
    openToMentors = roleProfile.openToMentors;
  }

  @override
  InnovatorProfile buildRoleProfile(String profileId) {
    return InnovatorProfileModel(
      profileId: profileId,
      bio: bioCtrl.text.trim(),
      startupName: startupNameCtrl.text.trim(),
      education: educationCtrl.text.trim(),
      portfolioUrl: portfolioUrlCtrl.text.trim(),
      githubUrl: githubUrlCtrl.text.trim(),
      linkedinUrl: linkedinUrlCtrl.text.trim(),
      resumeUrl: resumeUrlCtrl.text.trim(),
      twitterUrl: twitterUrlCtrl.text.trim(),
      skills: skills,
      experienceLevel: experienceLevel,
      currentStatus: currentStatus,
      preferredWorkMode: preferredWorkMode,
      buildingStartup: buildingStartup,
      openToCofounder: openToCofounder,
      openToInvestors: openToInvestors,
      openToMentors: openToMentors,
    );
  }

  @override
  List<TextEditingController> get allControllers => [
        ...super.allControllers,
        startupNameCtrl,
        educationCtrl,
        portfolioUrlCtrl,
        githubUrlCtrl,
        linkedinUrlCtrl,
        resumeUrlCtrl,
        twitterUrlCtrl,
        bioCtrl,
        skillInputCtrl,
      ];
}
