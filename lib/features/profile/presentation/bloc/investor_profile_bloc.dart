import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/domain/repositories/investor_repository.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_event.dart';
import 'package:startlink/features/profile/presentation/bloc/investor_profile_state.dart';

class InvestorProfileBloc extends Bloc<InvestorProfileEvent, InvestorProfileState> {
  final InvestorRepository _repository;
  final ProfileRepository _profileRepository;

  InvestorProfileBloc({
    required InvestorRepository repository,
    required ProfileRepository profileRepository,
  })  : _repository = repository,
        _profileRepository = profileRepository,
        super(InvestorProfileInitial()) {
    on<LoadInvestorProfile>(_onLoadProfile);
    on<UpdateInvestorProfile>(_onUpdateProfile);
    on<SubmitInvestorProfile>(_onUpdateProfile); // Reuse update logic
    on<SubmitVerification>(_onSubmitVerification);
    on<UpdateConsolidatedProfile>(_onUpdateConsolidatedProfile);
  }

  Future<void> _onLoadProfile(
    LoadInvestorProfile event,
    Emitter<InvestorProfileState> emit,
  ) async {
    emit(InvestorProfileLoading());
    try {
      final baseProfile = await _profileRepository.fetchProfileById(event.userId);
      final profile = await _repository.getProfile(event.userId);
      final verification = await _repository.getVerificationStatus(event.userId);

      if (profile != null) {
        emit(InvestorProfileLoaded(
          baseProfile: baseProfile,
          profile: profile,
          verification: verification,
        ));
      } else {
        emit(const InvestorProfileError('Investor profile not found. Please complete your setup.'));
      }
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    InvestorProfileEvent event,
    Emitter<InvestorProfileState> emit,
  ) async {
    final profile = (event is UpdateInvestorProfile) 
        ? event.profile 
        : (event as SubmitInvestorProfile).profile;
    
    emit(InvestorProfileSaving());
    try {
      await _repository.updateProfile(profile);
      emit(InvestorProfileSaved());
      // Reload profile after save
      add(LoadInvestorProfile(profile.profileId));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  Future<void> _onSubmitVerification(
    SubmitVerification event,
    Emitter<InvestorProfileState> emit,
  ) async {
    emit(InvestorProfileSaving());
    try {
      await _repository.submitVerification(event.userId);
      emit(InvestorProfileSaved());
      // Reload status
      add(LoadInvestorProfile(event.userId));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateConsolidatedProfile(
    UpdateConsolidatedProfile event,
    Emitter<InvestorProfileState> emit,
  ) async {
    emit(InvestorProfileSaving());
    try {
      // 1. Update base profile
      await _profileRepository.updateProfile(event.baseProfile);
      // 2. Update investor profile
      await _repository.updateProfile(event.investorProfile);
      
      emit(InvestorProfileSaved());
      // Reload profile after save
      add(LoadInvestorProfile(event.baseProfile.id));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }
}
