// lib/features/profile/presentation/widgets/profile_edit_framework/controllers/collaborator_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart';

class CollaboratorEditController extends ProfileEditController<CollaboratorProfile> {
  final yoeCtrl = TextEditingController();
  final hourlyRateCtrl = TextEditingController();
  final portfolioUrlCtrl = TextEditingController();
  final githubUrlCtrl = TextEditingController();
  final linkedinUrlCtrl = TextEditingController();
  final resumeUrlCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  final specInputCtrl = TextEditingController();
  final projTypeInputCtrl = TextEditingController();

  List<String> specialties = [];
  List<String> preferredProjectTypes = [];
  String? availability;

  @override
  void populate(ProfileModel baseProfile, CollaboratorProfile roleProfile) {
    nameCtrl.text = baseProfile.fullName ?? '';
    aboutCtrl.text = baseProfile.about ?? '';

    yoeCtrl.text = roleProfile.experienceYears?.toString() ?? '';
    hourlyRateCtrl.text = roleProfile.hourlyRate?.toString() ?? '';
    portfolioUrlCtrl.text = roleProfile.portfolioUrl ?? '';
    githubUrlCtrl.text = roleProfile.githubUrl ?? '';
    linkedinUrlCtrl.text = roleProfile.linkedinUrl ?? '';
    resumeUrlCtrl.text = roleProfile.resumeUrl ?? '';
    bioCtrl.text = roleProfile.bio ?? '';
    specialties = List.from(roleProfile.specialties);
    preferredProjectTypes = List.from(roleProfile.preferredProjectTypes);
    availability = roleProfile.availability;
  }

  @override
  CollaboratorProfile buildRoleProfile(String profileId) {
    return CollaboratorProfileModel(
      profileId: profileId,
      experienceYears: int.tryParse(yoeCtrl.text),
      hourlyRate: double.tryParse(hourlyRateCtrl.text),
      portfolioUrl: portfolioUrlCtrl.text.trim(),
      githubUrl: githubUrlCtrl.text.trim(),
      linkedinUrl: linkedinUrlCtrl.text.trim(),
      resumeUrl: resumeUrlCtrl.text.trim(),
      bio: bioCtrl.text.trim(),
      specialties: specialties,
      preferredProjectTypes: preferredProjectTypes,
      availability: availability,
    );
  }

  @override
  List<TextEditingController> get allControllers => [
        ...super.allControllers,
        yoeCtrl,
        hourlyRateCtrl,
        portfolioUrlCtrl,
        githubUrlCtrl,
        linkedinUrlCtrl,
        resumeUrlCtrl,
        bioCtrl,
        specInputCtrl,
        projTypeInputCtrl,
      ];
}
