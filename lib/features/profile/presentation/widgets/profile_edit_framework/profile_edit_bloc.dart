// lib/features/profile/presentation/widgets/profile_edit_framework/profile_edit_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/entities/mentor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_completion_service.dart';
import 'profile_edit_event.dart';
import 'profile_edit_state.dart';

class ProfileEditBloc<T> extends Bloc<ProfileEditEvent, ProfileEditState<T>> {
  final ProfileRepository repository;

  ProfileEditBloc({required this.repository}) : super(ProfileEditState<T>.initial()) {
    on<LoadProfile>(_onLoad);
    on<SaveProfile<T>>(_onSave);
    on<UpdateCompletion>(_onUpdateCompletion);
  }

  Future<void> _onLoad(LoadProfile event, Emitter<ProfileEditState<T>> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final base = await repository.fetchProfileById(event.profileId);
      final role = await _fetchRoleProfile(event.profileId);
      
      if (role == null) {
        emit(state.copyWith(isLoading: false, error: 'Profile details not found'));
        return;
      }

      final verification = await repository.fetchUserVerification(
        event.profileId,
        _getRoleString(),
      );

      emit(state.copyWith(
        isLoading: false,
        baseProfile: base,
        roleProfile: role,
        completionScore: _calculateScore(role),
        verificationStatus: _mapStringToStatus(verification?.status),
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSave(SaveProfile<T> event, Emitter<ProfileEditState<T>> emit) async {
    final currentScore = _calculateScore(event.roleProfile);
    
    emit(state.copyWith(
      isSaving: true,
      saveSuccess: false,
      baseProfile: event.baseProfile,
      roleProfile: event.roleProfile,
      completionScore: currentScore,
      error: null,
    ));
    
    try {
      // 1. Save base profile
      await repository.updateProfile(event.baseProfile);
      
      // 2. Save role profile
      await _upsertRoleProfile(event.roleProfile);
      
      final verification = await repository.fetchUserVerification(
        event.baseProfile.id,
        _getRoleString(),
      );

      emit(state.copyWith(
        isSaving: false,
        saveSuccess: true,
        baseProfile: event.baseProfile,
        roleProfile: event.roleProfile,
        completionScore: currentScore,
        verificationStatus: _mapStringToStatus(verification?.status),
      ));
    } catch (e) {
      emit(state.copyWith(isSaving: false, error: e.toString()));
    }
  }

  void _onUpdateCompletion(UpdateCompletion event, Emitter<ProfileEditState<T>> emit) {
    emit(state.copyWith(completionScore: event.score));
  }

  VerificationStatus _mapStringToStatus(String? status) {
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

  String _getRoleString() {
    if (T == InvestorProfile) return 'investor';
    if (T == MentorProfile) return 'mentor';
    if (T == CollaboratorProfile) return 'collaborator';
    if (T == InnovatorProfile) return 'innovator';
    return 'unknown';
  }

  Future<T?> _fetchRoleProfile(String id) async {
    if (T == InvestorProfile) return await repository.fetchInvestorProfile(id) as T?;
    if (T == MentorProfile) return await repository.fetchMentorProfile(id) as T?;
    if (T == CollaboratorProfile) return await repository.fetchCollaboratorProfile(id) as T?;
    if (T == InnovatorProfile) return await repository.fetchInnovatorProfile(id) as T?;
    return null;
  }

  Future<void> _upsertRoleProfile(T profile) async {
    if (profile is InvestorProfile) await repository.upsertInvestorProfile(profile);
    if (profile is MentorProfile) await repository.upsertMentorProfile(profile);
    if (profile is CollaboratorProfile) await repository.upsertCollaboratorProfile(profile);
    if (profile is InnovatorProfile) await repository.upsertInnovatorProfile(profile);
  }

  int _calculateScore(T profile) {
    if (profile is InvestorProfile) return ProfileCompletionService.calculateInvestor(profile);
    if (profile is MentorProfile) return ProfileCompletionService.calculateMentor(profile);
    if (profile is CollaboratorProfile) return ProfileCompletionService.calculateCollaborator(profile);
    if (profile is InnovatorProfile) return ProfileCompletionService.calculateInnovator(profile);
    return 0;
  }
}
