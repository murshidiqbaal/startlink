// lib/features/profile/presentation/widgets/profile_edit_framework/profile_edit_controller.dart

import 'package:flutter/material.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';

abstract class ProfileEditController<T> {
  // Base profile fields (profiles table)
  final nameCtrl = TextEditingController();
  final aboutCtrl = TextEditingController();

  /// Populate all controllers from existing data
  void populate(ProfileModel baseProfile, T roleProfile);

  /// Extract data from controllers into a role-specific model
  T buildRoleProfile(String profileId);

  /// Extract data from controllers into base profile model
  ProfileModel buildBaseProfile(ProfileModel existing) {
    return existing.copyWith(
      fullName: _noe(nameCtrl.text),
      about: _noe(aboutCtrl.text),
    );
  }

  /// Override this to include role-specific controllers
  List<TextEditingController> get allControllers => [nameCtrl, aboutCtrl];

  void dispose() {
    for (var c in allControllers) {
      c.dispose();
    }
  }

  String? _noe(String v) => v.trim().isEmpty ? null : v.trim();
  String _eon(String? v) => v ?? '';
}
