import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

// Events
abstract class InvestorProfileEvent extends Equatable {
  const InvestorProfileEvent();
  @override
  List<Object> get props => [];
}

class LoadInvestorProfile extends InvestorProfileEvent {
  final String profileId;
  const LoadInvestorProfile(this.profileId);
  @override
  List<Object> get props => [profileId];
}

class SaveInvestorProfile extends InvestorProfileEvent {
  final InvestorProfile profile;
  const SaveInvestorProfile(this.profile);
  @override
  List<Object> get props => [profile];
}


// States
abstract class InvestorProfileState extends Equatable {
  const InvestorProfileState();
  @override
  List<Object> get props => [];
}

class InvestorProfileInitial extends InvestorProfileState {}

class InvestorProfileLoading extends InvestorProfileState {}

class InvestorProfileLoaded extends InvestorProfileState {
  final InvestorProfile profile;
  final UserVerification? verification;
  final List<UserBadge> badges;

  const InvestorProfileLoaded({
    required this.profile,
    required this.badges,
    this.verification,
  });

  @override
  List<Object> get props => [profile, badges, verification ?? 'none'];
}

class InvestorProfileSaving extends InvestorProfileState {}

class InvestorProfileSaved extends InvestorProfileState {}


class InvestorProfileError extends InvestorProfileState {
  final String message;
  const InvestorProfileError(this.message);
  @override
  List<Object> get props => [message];
}

class InvestorProfileBloc
    extends Bloc<InvestorProfileEvent, InvestorProfileState> {
  final ProfileRepository _repository;

  InvestorProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(InvestorProfileInitial()) {
    on<LoadInvestorProfile>(_onLoad);
    on<SaveInvestorProfile>(_onSave);
  }

  Future<void> _onLoad(
    LoadInvestorProfile event,
    Emitter<InvestorProfileState> emit,
  ) async {
    emit(InvestorProfileLoading());
    try {
      final profile = await _repository.fetchInvestorProfile(event.profileId);
      final verification = await _repository.fetchUserVerification(
        event.profileId,
        'investor',
      );
      final badges = await _repository.fetchUserBadges(event.profileId);

      if (profile != null) {
        emit(
          InvestorProfileLoaded(
            profile: profile,
            verification: verification,
            badges: badges,
          ),
        );
      } else {
        emit(
          InvestorProfileLoaded(
            profile: InvestorProfileModel(profileId: event.profileId),
            verification: verification,
            badges: badges,
          ),
        );
      }
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }

  Future<void> _onSave(
    SaveInvestorProfile event,
    Emitter<InvestorProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is InvestorProfileLoaded) {
      emit(InvestorProfileSaving());
      try {
        await _repository.upsertInvestorProfile(event.profile);
        emit(InvestorProfileSaved());
        // Reload profile to refresh completion score and data
        add(LoadInvestorProfile(event.profile.profileId));
      } catch (e) {
        emit(InvestorProfileError(e.toString()));
        emit(currentState); // Revert to loaded state
      }
    }
  }

}
