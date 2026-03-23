import 'package:bloc/bloc.dart';
import 'package:startlink/core/constants/user_role.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/domain/utils/profile_completion_calculator.dart';
import 'package:startlink/features/role_management/presentation/bloc/profile_gate_event.dart';
import 'package:startlink/features/role_management/presentation/bloc/profile_gate_state.dart';

class ProfileGateBloc extends Bloc<ProfileGateEvent, ProfileGateState> {
  final ProfileRepository _profileRepository;

  ProfileGateBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileGateInitial()) {
    on<CheckProfileCompliance>(_onCheckProfileCompliance);
  }

  Future<void> _onCheckProfileCompliance(
    CheckProfileCompliance event,
    Emitter<ProfileGateState> emit,
  ) async {
    emit(ProfileGateLoading());
    try {
      // fetchProfileById throws exception if not found because of .single()
      final baseProfile = await _profileRepository.fetchProfileById(event.userId);

      int completion = 0;
      List<String> missing = []; // Simplified missing fields logic
      bool isAllowed = false;

      switch (event.role) {
        case UserRole.innovator:
          final roleProfile = await _profileRepository.fetchInnovatorProfile(
            event.userId,
          );
          // Auto-create empty if null?
          if (roleProfile == null) {
            // Logic to create empty profile would go here or be handled by user action
            // For now assume null means 0 completion
          }

          completion = ProfileCompletionCalculator.calculateInnovatorCompletion(
            baseProfile,
            roleProfile,
          );
          // Simplified checks for specific missing fields
          if (roleProfile == null) {
            missing.add("Create Innovator Profile");
          } else {
            if (roleProfile.skills.isEmpty) missing.add("Skills");
          }
          if (baseProfile.about == null || baseProfile.about!.isEmpty) {
            missing.add("About");
          }
          if (baseProfile.avatarUrl == null) missing.add("Profile Photo");

          isAllowed = completion >= 70;
          break;

        case UserRole.mentor:
          final roleProfile = await _profileRepository.fetchMentorProfile(
            event.userId,
          );
          completion = ProfileCompletionCalculator.calculateMentorCompletion(
            baseProfile,
            roleProfile,
          );
          if (roleProfile == null) {
            missing.add("Create Mentor Profile");
          } else {
            if (roleProfile.expertiseDomains.isEmpty) {
              missing.add("Expertise Domains");
            }
            if (roleProfile.yearsOfExperience == null) {
              missing.add("Years of Experience");
            }
            if (roleProfile.mentorshipFocus == null) {
              missing.add("Mentorship Focus");
            }
            if (roleProfile.linkedinUrl == null) missing.add("LinkedIn");
          }

          isAllowed = completion >= 80;
          break;

        case UserRole.investor:
          final roleProfile = await _profileRepository.fetchInvestorProfile(
            event.userId,
          );
          completion = ProfileCompletionCalculator.calculateInvestorCompletion(
            baseProfile,
            roleProfile,
          );
          if (roleProfile == null) {
            missing.add("Create Investor Profile");
          } else {
            if (roleProfile.investmentFocus == null) {
              missing.add("Investment Focus");
            }
            if (roleProfile.ticketSizeMin == null) missing.add("Ticket Size");
            if (roleProfile.preferredStage == null) {
              missing.add("Preferred Stage");
            }
            if (roleProfile.organizationName == null) {
              missing.add("Organization");
            }
            if (roleProfile.linkedinUrl == null) missing.add("LinkedIn");
          }

          isAllowed = completion >= 85;
          break;

        case UserRole.collaborator:
          isAllowed = true; // No profile requirements for now
          break;
      }

      if (isAllowed) {
        emit(ProfileGateAllowed(event.role));
      } else {
        emit(
          ProfileGateBlocked(
            role: event.role,
            missingFields: missing,
            completionPercentage: completion,
            baseProfile: baseProfile,
          ),
        );
      }
    } catch (e) {
      emit(ProfileGateError(e.toString()));
    }
  }
}
