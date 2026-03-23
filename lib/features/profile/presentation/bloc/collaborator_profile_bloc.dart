import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/features/profile/data/models/collaborator_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/collaborator_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';

// --- Events ---
abstract class CollaboratorProfileEvent extends Equatable {
  const CollaboratorProfileEvent();
  @override
  List<Object?> get props => [];
}

class FetchCollaboratorProfile extends CollaboratorProfileEvent {
  final String profileId;
  const FetchCollaboratorProfile(this.profileId);
  @override
  List<Object?> get props => [profileId];
}

class UpdateCollaboratorProfile extends CollaboratorProfileEvent {
  final CollaboratorProfile profile;
  const UpdateCollaboratorProfile(this.profile);
  @override
  List<Object?> get props => [profile];
}

// --- States ---
abstract class CollaboratorProfileState extends Equatable {
  const CollaboratorProfileState();
  @override
  List<Object?> get props => [];
}

class CollaboratorProfileInitial extends CollaboratorProfileState {}

class CollaboratorProfileLoading extends CollaboratorProfileState {}

class CollaboratorProfileLoaded extends CollaboratorProfileState {
  final CollaboratorProfile profile;
  const CollaboratorProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}

class CollaboratorProfileError extends CollaboratorProfileState {
  final String message;
  const CollaboratorProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

class CollaboratorProfileUpdated extends CollaboratorProfileState {}

// --- Bloc ---
class CollaboratorProfileBloc
    extends Bloc<CollaboratorProfileEvent, CollaboratorProfileState> {
  final ProfileRepository repository;

  CollaboratorProfileBloc({required this.repository})
    : super(CollaboratorProfileInitial()) {
    on<FetchCollaboratorProfile>(_onFetch);
    on<UpdateCollaboratorProfile>(_onUpdate);
  }

  Future<void> _onFetch(
    FetchCollaboratorProfile event,
    Emitter<CollaboratorProfileState> emit,
  ) async {
    emit(CollaboratorProfileLoading());
    try {
      final profile = await repository.fetchCollaboratorProfile(
        event.profileId,
      );
      if (profile != null) {
        emit(CollaboratorProfileLoaded(profile));
      } else {
        // If not found, create a blank one or stay in initial
        emit(
          CollaboratorProfileLoaded(
            CollaboratorProfileModel(profileId: event.profileId)
                as CollaboratorProfile,
          ),
        );
      }
    } catch (e) {
      emit(CollaboratorProfileError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateCollaboratorProfile event,
    Emitter<CollaboratorProfileState> emit,
  ) async {
    emit(CollaboratorProfileLoading());
    try {
      await repository.upsertCollaboratorProfile(event.profile);
      emit(CollaboratorProfileUpdated());
      // Re-fetch or pass back
      emit(CollaboratorProfileLoaded(event.profile));
    } catch (e) {
      emit(CollaboratorProfileError(e.toString()));
    }
  }
}
