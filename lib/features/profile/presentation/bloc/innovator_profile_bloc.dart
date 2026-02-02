import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/profile/domain/entities/innovator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';

// Events
abstract class InnovatorProfileEvent extends Equatable {
  const InnovatorProfileEvent();
  @override
  List<Object> get props => [];
}

class LoadInnovatorProfile extends InnovatorProfileEvent {
  final String profileId;
  const LoadInnovatorProfile(this.profileId);
  @override
  List<Object> get props => [profileId];
}

class SaveInnovatorProfile extends InnovatorProfileEvent {
  final InnovatorProfile profile;
  const SaveInnovatorProfile(this.profile);
  @override
  List<Object> get props => [profile];
}

// States
abstract class InnovatorProfileState extends Equatable {
  const InnovatorProfileState();
  @override
  List<Object> get props => [];
}

class InnovatorProfileInitial extends InnovatorProfileState {}

class InnovatorProfileLoading extends InnovatorProfileState {}

class InnovatorProfileLoaded extends InnovatorProfileState {
  final InnovatorProfile profile;
  const InnovatorProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
}

class InnovatorProfileError extends InnovatorProfileState {
  final String message;
  const InnovatorProfileError(this.message);
  @override
  List<Object> get props => [message];
}

class InnovatorProfileBloc
    extends Bloc<InnovatorProfileEvent, InnovatorProfileState> {
  final ProfileRepository _repository;

  InnovatorProfileBloc({required ProfileRepository repository})
    : _repository = repository,
      super(InnovatorProfileInitial()) {
    on<LoadInnovatorProfile>(_onLoad);
    on<SaveInnovatorProfile>(_onSave);
  }

  Future<void> _onLoad(
    LoadInnovatorProfile event,
    Emitter<InnovatorProfileState> emit,
  ) async {
    emit(InnovatorProfileLoading());
    try {
      final profile = await _repository.getInnovatorProfile(event.profileId);
      if (profile != null) {
        emit(InnovatorProfileLoaded(profile));
      } else {
        // Assume creating new profile if not found
        emit(
          InnovatorProfileLoaded(InnovatorProfile(profileId: event.profileId)),
        );
      }
    } catch (e) {
      emit(InnovatorProfileError(e.toString()));
    }
  }

  Future<void> _onSave(
    SaveInnovatorProfile event,
    Emitter<InnovatorProfileState> emit,
  ) async {
    emit(InnovatorProfileLoading());
    try {
      await _repository.updateInnovatorProfile(event.profile);
      emit(InnovatorProfileLoaded(event.profile));
    } catch (e) {
      emit(InnovatorProfileError(e.toString()));
    }
  }
}
