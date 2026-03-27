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
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
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
  final AuthRepository _authRepo;

  RoleProfileBloc({
    required ProfileRepository repository,
    required AuthRepository authRepository,
  })  : _repo = repository,
        _authRepo = authRepository,
        super(RoleProfileInitial()) {
    on<LoadRoleProfile>(_onLoad);
    on<UpdateRoleProfile>(_onUpdateProfile);
    on<SubmitVerificationRequest>(_onSubmitVerification);
    on<UpdateRoleCompletion>(_onUpdateCompletion);
  }

  // ── Load ────────────────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadRoleProfile event,
    Emitter<RoleProfileState> emit,
  ) async {
    final userId = _authRepo.currentUser?.id;
    if (userId == null) {
      emit(const RoleProfileError('User not authenticated'));
      return;
    }

    emit(RoleProfileLoading());
    try {
      final base = await _repo.fetchProfileById(userId);
      final roleProfile = await _fetchRoleProfile(userId, event.role);

      final verification = await _repo.fetchUserVerification(
        userId,
        event.role,
      );

      final completion = roleProfile != null
          ? ProfileCompletionService.calculate(roleProfile)
          : 0;

      emit(_createLoadedState(
        role: event.role,
        base: base,
        profile: roleProfile ?? _createDefaultProfile(userId, event.role),
        completion: completion,
        status: _mapStatus(verification?.status),
      ));
    } catch (e, st) {
      debugPrint('[RoleProfileBloc] load error: $e\n$st');
      emit(RoleProfileError(e.toString()));
    }
  }

  // ── Update ──────────────────────────────────────────────────────────────────

  Future<void> _onUpdateProfile(
    UpdateRoleProfile event,
    Emitter<RoleProfileState> emit,
  ) async {
    emit(RoleProfileSaving());

    try {
      // 1. Save base profile row
      await _repo.updateProfile(event.baseProfile);

      // 2. Save role-specific row
      await _saveRoleProfile(event.roleProfile);

      // 3. Re-fetch verification status to ensure everything is synced
      await _repo.fetchUserVerification(
        event.baseProfile.id,
        event.roleProfile.role,
      );

      emit(RoleProfileSaved());
      
      // Immediately reload to get fresh data
      add(LoadRoleProfile(role: event.roleProfile.role));
    } catch (e, st) {
      debugPrint('[RoleProfileBloc] save error: $e\n$st');
      emit(RoleProfileError(e.toString()));
    }
  }

  // ── Verification ────────────────────────────────────────────────────────────

  Future<void> _onSubmitVerification(
    SubmitVerificationRequest event,
    Emitter<RoleProfileState> emit,
  ) async {
    try {
      await _repo.createVerificationRequest(
        event.profileId,
        event.role,
      );
      
      // Reload to update verification status
      add(LoadRoleProfile(role: event.role));
    } catch (e, st) {
      debugPrint('[RoleProfileBloc] verification error: $e\n$st');
      emit(RoleProfileError(e.toString()));
    }
  }

  // ── Completion update ───────────────────────────────────────────────────────

  void _onUpdateCompletion(
    UpdateRoleCompletion event,
    Emitter<RoleProfileState> emit,
  ) {
    final s = state;
    if (s is RoleProfileLoaded) {
      if (s is InvestorProfileLoaded) {
        emit(s.copyWith(completionScore: event.score));
      } else if (s is MentorProfileLoaded) {
        emit(s.copyWith(completionScore: event.score));
      } else if (s is InnovatorProfileLoaded) {
        emit(s.copyWith(completionScore: event.score));
      } else if (s is CollaboratorProfileLoaded) {
        emit(s.copyWith(completionScore: event.score));
      }
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  RoleProfileLoaded _createLoadedState({
    required String role,
    required ProfileModel base,
    required RoleProfile profile,
    required int completion,
    required VerificationStatus status,
  }) {
    switch (role.toLowerCase()) {
      case 'investor':
        return InvestorProfileLoaded(
          baseProfile: base,
          investorProfile: profile as InvestorProfile,
          completionScore: completion,
          verificationStatus: status,
        );
      case 'mentor':
        return MentorProfileLoaded(
          baseProfile: base,
          mentorProfile: profile as MentorProfile,
          completionScore: completion,
          verificationStatus: status,
        );
      case 'collaborator':
        return CollaboratorProfileLoaded(
          baseProfile: base,
          collaboratorProfile: profile as CollaboratorProfile,
          completionScore: completion,
          verificationStatus: status,
        );
      default:
        return InnovatorProfileLoaded(
          baseProfile: base,
          innovatorProfile: profile as InnovatorProfile,
          completionScore: completion,
          verificationStatus: status,
        );
    }
  }

  RoleProfile _createDefaultProfile(String id, String role) {
    switch (role.toLowerCase()) {
      case 'investor':
        return InvestorProfile(profileId: id);
      case 'mentor':
        return MentorProfile(profileId: id);
      case 'collaborator':
        return CollaboratorProfile(profileId: id);
      default:
        return InnovatorProfile(profileId: id);
    }
  }

  Future<RoleProfile?> _fetchRoleProfile(String id, String role) async {
    switch (role.toLowerCase()) {
      case 'investor':
        return _repo.fetchInvestorProfile(id);
      case 'mentor':
        return _repo.fetchMentorProfile(id);
      case 'collaborator':
        return _repo.fetchCollaboratorProfile(id);
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
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.notVerified;
    }
  }
}
