// lib/features/profile/presentation/bloc/role_profile_state.dart
//
// Non-generic state for RoleProfileBloc.
// `profile` is typed as the abstract `RoleProfile` — UI uses `is` runtime
// checks (e.g. `if (state.profile is InvestorProfile)`) to access role fields.
// This completely eliminates the generic type-mismatch crashes.

import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/data/models/profile_model.dart';
import 'package:startlink/features/profile/domain/entities/role_profile.dart';
import 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart';

// Re-export so existing imports keep working
export 'package:startlink/features/profile/presentation/widgets/profile_edit_framework/profile_edit_state.dart'
    show VerificationStatus;

class RoleProfileState extends Equatable {
  /// The base `profiles` row — contains name, avatar, headline, etc.
  final ProfileModel? baseProfile;

  /// The role-specific profile row. Cast with `is` at the call site:
  ///   if (state.profile is InvestorProfile) { ... }
  final RoleProfile? profile;

  final bool isLoading;
  final bool isSaving;
  final bool saveSuccess;
  final String? error;

  // VerificationStatus is imported from profile_edit_state.dart via export above
  // to avoid duplicate enum definitions.
  final VerificationStatus verificationStatus;
  final int completionScore;

  const RoleProfileState({
    this.baseProfile,
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.error,
    this.verificationStatus = VerificationStatus.notVerified,
    this.completionScore = 0,
  });

  factory RoleProfileState.initial() => const RoleProfileState();

  RoleProfileState copyWith({
    ProfileModel? baseProfile,
    RoleProfile? profile,
    bool? isLoading,
    bool? isSaving,
    bool? saveSuccess,
    String? error,
    VerificationStatus? verificationStatus,
    int? completionScore,
    bool clearError = false,
  }) {
    return RoleProfileState(
      baseProfile: baseProfile ?? this.baseProfile,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      error: clearError ? null : (error ?? this.error),
      verificationStatus: verificationStatus ?? this.verificationStatus,
      completionScore: completionScore ?? this.completionScore,
    );
  }

  @override
  List<Object?> get props => [
    baseProfile,
    profile,
    isLoading,
    isSaving,
    saveSuccess,
    error,
    verificationStatus,
    completionScore,
  ];
}
