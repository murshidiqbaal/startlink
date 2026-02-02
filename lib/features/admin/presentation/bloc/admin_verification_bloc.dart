import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/admin/domain/repositories/admin_verification_repository.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';

// Events
abstract class AdminVerificationEvent extends Equatable {
  const AdminVerificationEvent();
  @override
  List<Object> get props => [];
}

class FetchRequests extends AdminVerificationEvent {}

class ApproveRequest extends AdminVerificationEvent {
  final String verificationId;
  final String profileId;
  const ApproveRequest(this.verificationId, this.profileId);
  @override
  List<Object> get props => [verificationId, profileId];
}

class RejectRequest extends AdminVerificationEvent {
  final String verificationId;
  final String reason;
  const RejectRequest(this.verificationId, this.reason);
  @override
  List<Object> get props => [verificationId, reason];
}

// States
abstract class AdminVerificationState extends Equatable {
  const AdminVerificationState();
  @override
  List<Object> get props => [];
}

class AdminVerificationInitial extends AdminVerificationState {}

class AdminVerificationLoading extends AdminVerificationState {}

class AdminVerificationLoaded extends AdminVerificationState {
  final List<UserVerification> pending;
  final List<UserVerification> approved;
  final List<UserVerification> rejected;

  const AdminVerificationLoaded({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  @override
  List<Object> get props => [pending, approved, rejected];
}

class AdminVerificationError extends AdminVerificationState {
  final String message;
  const AdminVerificationError(this.message);
  @override
  List<Object> get props => [message];
}

class AdminVerificationBloc
    extends Bloc<AdminVerificationEvent, AdminVerificationState> {
  final AdminVerificationRepository _repository;

  AdminVerificationBloc({required AdminVerificationRepository repository})
    : _repository = repository,
      super(AdminVerificationInitial()) {
    on<FetchRequests>(_onFetch);
    on<ApproveRequest>(_onApprove);
    on<RejectRequest>(_onReject);
  }

  Future<void> _onFetch(
    FetchRequests event,
    Emitter<AdminVerificationState> emit,
  ) async {
    emit(AdminVerificationLoading());
    try {
      final pending = await _repository.getPendingVerifications();
      final approved = await _repository.getApprovedVerifications();
      final rejected = await _repository.getRejectedVerifications();
      emit(
        AdminVerificationLoaded(
          pending: pending,
          approved: approved,
          rejected: rejected,
        ),
      );
    } catch (e) {
      emit(AdminVerificationError(e.toString()));
    }
  }

  Future<void> _onApprove(
    ApproveRequest event,
    Emitter<AdminVerificationState> emit,
  ) async {
    try {
      await _repository.approveVerification(
        event.verificationId,
        event.profileId,
      );
      add(FetchRequests());
    } catch (e) {
      emit(AdminVerificationError(e.toString()));
    }
  }

  Future<void> _onReject(
    RejectRequest event,
    Emitter<AdminVerificationState> emit,
  ) async {
    try {
      await _repository.rejectVerification(event.verificationId, event.reason);
      add(FetchRequests());
    } catch (e) {
      emit(AdminVerificationError(e.toString()));
    }
  }
}
