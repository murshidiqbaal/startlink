// lib/features/profile/presentation/bloc/unified_role_profile_bloc.dart
//
// THE single, non-generic BLoC that handles ALL role profiles.
//
// Key design decisions:
//  • State stores `RoleProfile?` (base type) — no generics.
//  • Runtime `is` checks dispatch to the correct repository call.
//  • Eliminates ALL "type 'X' is not a subtype of type 'Null'" errors.
//  • Verification request is auto-triggered when completion >= 80.

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_state.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_completion_service.dart';

class RoleProfileBloc extends Bloc<RoleProfileEvent, RoleProfileState> {
  final ProfileRepository _repo;

  RoleProfileBloc({required ProfileRepository repository})
      : _repo = repository,
        super(RoleProfileState.initial()) {
    on<LoadRoleProfile>(_onLoad);
    on<SaveRoleProfile>(_onSave);
    on<UpdateRoleCompletion>(_onUpdateCompletion);
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadRoleProfile event,
    Emitter<RoleProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, saveSuccess: false));
    try {
      final base = await _repo.fetchProfileById(event.profileId);
      final roleProfile = await _fetchRoleProfile(event.profileId, event.role);

      final verification = await _repo.fetchUserVerification(
        event.profileId,
        event.role,
      );

      final completion = roleProfile != null
          ? ProfileCompletionService.calculate(roleProfile)
          : 0;

      emit(state.copyWith(
        isLoading: false,
        baseProfile: base,
        profile: roleProfile,
        completionScore: completion,
        verificationStatus: _mapStatus(verification?.status),
      ));
    } catch (e, st) {
      debugPrint('[RoleProfileBloc] load error: $e\n$st');
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // ── Save ────────────────────────────────────────────────────────────────────

  Future<void> _onSave(
    SaveRoleProfile event,
    Emitter<RoleProfileState> emit,
  ) async {
    final score = ProfileCompletionService.calculate(event.roleProfile);

    emit(state.copyWith(
      isSaving: true,
      saveSuccess: false,
      baseProfile: event.baseProfile,
      profile: event.roleProfile,
      completionScore: score,
      clearError: true,
    ));

    try {
      // 1. Save base profile row
      await _repo.updateProfile(event.baseProfile);

      // 2. Save role-specific row (dispatch by type)
      await _saveRoleProfile(event.roleProfile);

      // 3. Auto-trigger verification if threshold reached
      if (score >= 80) {
        await _repo.createVerificationRequest(
          event.baseProfile.id,
          event.roleProfile.role,
        );
      }

      // 4. Re-fetch verification status
      final verification = await _repo.fetchUserVerification(
        event.baseProfile.id,
        event.roleProfile.role,
      );

      emit(state.copyWith(
        isSaving: false,
        saveSuccess: true,
        completionScore: score,
        verificationStatus: _mapStatus(verification?.status),
      ));
    } catch (e, st) {
      debugPrint('[RoleProfileBloc] save error: $e\n$st');
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  // ── Completion update ───────────────────────────────────────────────────────

  void _onUpdateCompletion(
    UpdateRoleCompletion event,
    Emitter<RoleProfileState> emit,
  ) {
    emit(state.copyWith(completionScore: event.score));
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  Future<RoleProfile?> _fetchRoleProfile(String id, String role) async {
    switch (role) {
      case 'investor':
        return _repo.fetchInvestorProfile(id);
      case 'mentor':
        return _repo.fetchMentorProfile(id);
      case 'collaborator':
        return _repo.fetchCollaboratorProfile(id);
      case 'innovator':
      default:
        return _repo.fetchInnovatorProfile(id);
    }
  }

  Future<void> _saveRoleProfile(RoleProfile profile) async {
    if (profile is InvestorProfile) {
      await _repo.upsertInvestorProfile(profile);
    } else if (profile is MentorProfile) {
      await _repo.upsertMentorProfile(profile);
    } else if (profile is CollaboratorProfile) {
      await _repo.upsertCollaboratorProfile(profile);
    } else if (profile is InnovatorProfile) {
      await _repo.upsertInnovatorProfile(profile);
    }
  }

  VerificationStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
      case 'verified':
        return VerificationStatus.verified;
      case 'pending':
        return VerificationStatus.pending;
      default:
        return VerificationStatus.notVerified;
    }
  }
}
