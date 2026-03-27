// lib/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart

import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';

enum VerificationStatus { verified, pending, rejected, notVerified }

class ProfileEditState<T> extends Equatable {
  final ProfileModel? baseProfile;
  final T? roleProfile;
  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? error;
  final VerificationStatus verificationStatus;
  final int completionScore;

  const ProfileEditState({
    this.baseProfile,
    this.roleProfile,
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.error,
    this.verificationStatus = VerificationStatus.notVerified,
    this.completionScore = 0,
  });

  factory ProfileEditState.initial() => const ProfileEditState();

  ProfileEditState<T> copyWith({
    ProfileModel? baseProfile,
    T? roleProfile,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? error,
    VerificationStatus? verificationStatus,
    int? completionScore,
  }) {
    return ProfileEditState<T>(
      baseProfile: baseProfile ?? this.baseProfile,
      roleProfile: roleProfile ?? this.roleProfile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      error: error ?? this.error,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      completionScore: completionScore ?? this.completionScore,
    );
  }

  @override
  List<Object?> get props => [
        baseProfile,
        roleProfile,
        isLoading,
        isSaving,
        saveSuccess,
        error,
        verificationStatus,
        completionScore,
      ];
}
