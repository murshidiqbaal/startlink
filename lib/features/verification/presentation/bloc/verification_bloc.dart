import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/verification/domain/repositories/verification_repository.dart';

// Events
abstract class VerificationEvent extends Equatable {
  const VerificationEvent();
  @override
  List<Object> get props => [];
}

class CheckVerificationStatus extends VerificationEvent {
  final String profileId;
  final String role;
  const CheckVerificationStatus(this.profileId, this.role);
  @override
  List<Object> get props => [profileId, role];
}

class SubmitVerificationRequest extends VerificationEvent {
  final String profileId;
  final String role;
  final String type;
  const SubmitVerificationRequest({
    required this.profileId,
    required this.role,
    this.type = 'profile_review',
  });
  @override
  List<Object> get props => [profileId, role, type];
}

// States
abstract class VerificationState extends Equatable {
  const VerificationState();
  @override
  List<Object> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationPending extends VerificationState {
  final UserVerification verification;
  const VerificationPending(this.verification);
  @override
  List<Object> get props => [verification];
}

class VerificationApproved extends VerificationState {
  final List<UserBadge> badges;
  const VerificationApproved(this.badges);
  @override
  List<Object> get props => [badges];
}

class VerificationRejected extends VerificationState {
  final UserVerification verification;
  const VerificationRejected(this.verification);
  @override
  List<Object> get props => [verification];
}

class VerificationNotSubmitted extends VerificationState {}

class VerificationError extends VerificationState {
  final String message;
  const VerificationError(this.message);
  @override
  List<Object> get props => [message];
}

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository _repository;

  VerificationBloc({required VerificationRepository repository})
    : _repository = repository,
      super(VerificationInitial()) {
    on<CheckVerificationStatus>(_onCheckStatus);
    on<SubmitVerificationRequest>(_onSubmitRequest);
  }

  Future<void> _onCheckStatus(
    CheckVerificationStatus event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());
    try {
      final verifications = await _repository.getVerifications(event.profileId);
      final badges = await _repository.getBadges(event.profileId);

      // Check for role-specific badge first (Approved state)
      final badgeKey = 'verified_${event.role.toLowerCase()}';
      if (badges.any((b) => b.badgeKey == badgeKey)) {
        emit(VerificationApproved(badges));
        return;
      }

      // Check for pending/rejected requests for this role
      if (verifications.isNotEmpty) {
        // Get the latest for this role
        final roleVerifications = verifications
            .where((v) => v.role.toLowerCase() == event.role.toLowerCase())
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        if (roleVerifications.isNotEmpty) {
          final latest = roleVerifications.first;
          if (latest.status.toLowerCase() == 'pending') {
            emit(VerificationPending(latest));
            return;
          } else if (latest.status.toLowerCase() == 'rejected') {
            emit(VerificationRejected(latest));
            return;
          } else if (latest.status.toLowerCase() == 'approved') {
            // Should have caught badge already, but fallback
            emit(VerificationApproved(badges));
            return;
          }
        }
      }

      emit(VerificationNotSubmitted());
    } catch (e) {
      emit(VerificationError(e.toString()));
    }
  }

  Future<void> _onSubmitRequest(
    SubmitVerificationRequest event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());
    try {
      await _repository.requestVerification(
        event.profileId,
        event.role,
        event.type,
      );
      add(CheckVerificationStatus(event.profileId, event.role));
    } catch (e) {
      emit(VerificationError(e.toString()));
    }
  }
}
