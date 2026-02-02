import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';

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
  const InvestorProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
}

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
      final profile = await _repository.getInvestorProfile(event.profileId);
      if (profile != null) {
        emit(InvestorProfileLoaded(profile));
      } else {
        emit(
          InvestorProfileLoaded(InvestorProfile(profileId: event.profileId)),
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
    emit(InvestorProfileLoading());
    try {
      await _repository.updateInvestorProfile(event.profile);
      emit(InvestorProfileLoaded(event.profile));
    } catch (e) {
      emit(InvestorProfileError(e.toString()));
    }
  }
}
