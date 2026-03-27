// lib/features/profile/presentation/widgets/profile_edit_framework/controllers/investor_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart';

class InvestorEditController extends ProfileEditController<InvestorProfile> {
  final orgCtrl = TextEditingController();
  final focusCtrl = TextEditingController();
  final minTicketCtrl = TextEditingController();
  final maxTicketCtrl = TextEditingController();
  final linkedinCtrl = TextEditingController();
  final bioCtrl = TextEditingController();
  String? stage;

  @override
  void populate(ProfileModel baseProfile, InvestorProfile roleProfile) {
    nameCtrl.text = baseProfile.fullName ?? '';
    aboutCtrl.text = baseProfile.about ?? '';

    orgCtrl.text = roleProfile.organizationName ?? '';
    focusCtrl.text = roleProfile.investmentFocus ?? '';
    minTicketCtrl.text = roleProfile.ticketSizeMin?.toStringAsFixed(0) ?? '';
    maxTicketCtrl.text = roleProfile.ticketSizeMax?.toStringAsFixed(0) ?? '';
    linkedinCtrl.text = roleProfile.linkedinUrl ?? '';
    bioCtrl.text = roleProfile.bio ?? '';
    stage = roleProfile.preferredStage;
  }

  @override
  InvestorProfile buildRoleProfile(String profileId) {
    final focus = focusCtrl.text.trim();
    final minTicket = double.tryParse(minTicketCtrl.text);
    final maxTicket = double.tryParse(maxTicketCtrl.text);
    final org = orgCtrl.text.trim();
    final linkedin = linkedinCtrl.text.trim();
    final bio = bioCtrl.text.trim();

    return InvestorProfileModel(
      profileId: profileId,
      organizationName: org,
      investmentFocus: focus,
      ticketSizeMin: minTicket,
      ticketSizeMax: maxTicket,
      preferredStage: stage,
      linkedinUrl: linkedin,
      bio: bio,
      profileCompletion: InvestorProfileModel.calculateCompletion(
        investmentFocus: focus,
        ticketSizeMin: minTicket,
        ticketSizeMax: maxTicket,
        preferredStage: stage,
        organizationName: org,
        linkedinUrl: linkedin,
      ),
    );
  }

  @override
  List<TextEditingController> get allControllers => [
        ...super.allControllers,
        orgCtrl,
        focusCtrl,
        minTicketCtrl,
        maxTicketCtrl,
        linkedinCtrl,
        bioCtrl,
      ];
}
