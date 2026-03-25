import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/verification/domain/entities/user_badge.dart';
import 'package:startlink/features/verification/domain/entities/user_verification.dart';
import 'package:startlink/features/verification/domain/repositories/verification_repository.dart';
import 'package:startlink/features/verification/domain/utils/verification_rule_engine.dart';

// Events
abstract class VerificationEvent extends Equatable {
  const VerificationEvent();
  @override
  List<Object> get props => [];
}

class FetchVerificationsAndBadges extends VerificationEvent {
  final String profileId;
  const FetchVerificationsAndBadges(this.profileId);
  @override
  List<Object> get props => [profileId];
}

class RequestVerification extends VerificationEvent {
  final String profileId;
  final String role;
  final String type;
  const RequestVerification(this.profileId, this.role, this.type);
  @override
  List<Object> get props => [profileId, role, type];
}

class CheckBadgeRules extends VerificationEvent {
  // Trigger this when profile is updated
  final String profileId;
  final String role;
  final int completionScore;
  final bool isRoleVerified;

  const CheckBadgeRules({
    required this.profileId,
    required this.role,
    required this.completionScore,
    required this.isRoleVerified,
  });

  @override
  List<Object> get props => [profileId, role, completionScore, isRoleVerified];
}

// States
abstract class VerificationState extends Equatable {
  const VerificationState();
  @override
  List<Object> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class VerificationLoaded extends VerificationState {
  final List<UserVerification> verifications;
  final List<UserBadge> badges;
  final String profileId;

  const VerificationLoaded({
    this.verifications = const [],
    this.badges = const [],
    required this.profileId,
  });

  bool get isProfileVerified =>
      badges.any((b) => b.badgeKey == 'profile_verified');

  bool isRoleVerified(String role) {
    final badgeKey = 'verified_${role.toLowerCase()}';
    return badges.any((b) => b.badgeKey == badgeKey);
  }

  UserVerification? getRequestForRole(String role) {
    try {
      return verifications.firstWhere(
        (v) => v.role.toLowerCase() == role.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object> get props => [verifications, badges, profileId];
}

class VerificationError extends VerificationState {
  final String message;
  const VerificationError(this.message);
  @override
  List<Object> get props => [message];
}

class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  final VerificationRepository _repository;
  final VerificationRuleEngine _ruleEngine;

  VerificationBloc({required VerificationRepository repository})
    : _repository = repository,
      _ruleEngine = VerificationRuleEngine(repository),
      super(VerificationInitial()) {
    on<FetchVerificationsAndBadges>(_onFetch);
    on<RequestVerification>(_onSubmitRequest);
    on<CheckBadgeRules>(_onCheckRules);
  }

  Future<void> _onFetch(
    FetchVerificationsAndBadges event,
    Emitter<VerificationState> emit,
  ) async {
    emit(VerificationLoading());
    try {
      final verifications = await _repository.getVerifications(event.profileId);
      final badges = await _repository.getBadges(event.profileId);
      emit(
        VerificationLoaded(
          verifications: verifications,
          badges: badges,
          profileId: event.profileId,
        ),
      );
    } catch (e) {
      emit(VerificationError(e.toString()));
    }
  }

  Future<void> _onSubmitRequest(
    RequestVerification event,
    Emitter<VerificationState> emit,
  ) async {
    try {
      await _repository.requestVerification(
        event.profileId,
        event.role,
        event.type,
      );
      // Reload logic
      add(FetchVerificationsAndBadges(event.profileId));
    } catch (e) {
      emit(VerificationError(e.toString()));
    }
  }

  Future<void> _onCheckRules(
    CheckBadgeRules event,
    Emitter<VerificationState> emit,
  ) async {
    await _ruleEngine.evaluateProfileBadges(
      event.profileId,
      event.role,
      event.completionScore,
      event.isRoleVerified,
    );
    add(FetchVerificationsAndBadges(event.profileId));
  }
}
