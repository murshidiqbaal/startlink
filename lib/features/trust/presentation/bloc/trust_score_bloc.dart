import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/trust/domain/repositories/trust_repository.dart';
import 'package:startlink/features/trust/domain/utils/trust_score_calculator.dart';

// Events
abstract class TrustScoreEvent extends Equatable {
  const TrustScoreEvent();
  @override
  List<Object> get props => [];
}

class FetchTrustScore extends TrustScoreEvent {
  final String profileId;
  const FetchTrustScore(this.profileId);
  @override
  List<Object> get props => [profileId];
}

class CalculateAndUpdateTrustScore extends TrustScoreEvent {
  final String profileId;
  final String role;
  // Inputs for calculation
  final int completion;
  final bool isVerified;
  final bool isRoleVerified;
  final int ideaCount;
  final int collabCount;

  const CalculateAndUpdateTrustScore({
    required this.profileId,
    required this.role,
    required this.completion,
    required this.isVerified,
    required this.isRoleVerified,
    required this.ideaCount,
    required this.collabCount,
  });

  @override
  List<Object> get props => [
    profileId,
    role,
    completion,
    isVerified,
    isRoleVerified,
    ideaCount,
    collabCount,
  ];
}

// States
abstract class TrustScoreState extends Equatable {
  const TrustScoreState();
  @override
  List<Object> get props => [];
}

class TrustScoreInitial extends TrustScoreState {}

class TrustScoreLoading extends TrustScoreState {}

class TrustScoreLoaded extends TrustScoreState {
  final int score;
  const TrustScoreLoaded(this.score);
  @override
  List<Object> get props => [score];
}

class TrustScoreError extends TrustScoreState {
  final String message;
  const TrustScoreError(this.message);
  @override
  List<Object> get props => [message];
}

class TrustScoreBloc extends Bloc<TrustScoreEvent, TrustScoreState> {
  final TrustRepository _repository;

  TrustScoreBloc({required TrustRepository repository})
    : _repository = repository,
      super(TrustScoreInitial()) {
    on<FetchTrustScore>(_onFetch);
    on<CalculateAndUpdateTrustScore>(_onCalculate);
  }

  Future<void> _onFetch(
    FetchTrustScore event,
    Emitter<TrustScoreState> emit,
  ) async {
    emit(TrustScoreLoading());
    try {
      final score = await _repository.getTrustScore(event.profileId);
      emit(TrustScoreLoaded(score));
    } catch (e) {
      emit(TrustScoreError(e.toString()));
    }
  }

  Future<void> _onCalculate(
    CalculateAndUpdateTrustScore event,
    Emitter<TrustScoreState> emit,
  ) async {
    final score = TrustScoreCalculator.calculate(
      completion: event.completion,
      isVerified: event.isVerified,
      isRoleVerified: event.isRoleVerified,
      ideaCount: event.ideaCount,
      collabCount: event.collabCount,
    );

    try {
      await _repository.updateTrustScore(event.profileId, event.role, score);
      emit(TrustScoreLoaded(score));
    } catch (e) {
      emit(TrustScoreError(e.toString()));
    }
  }
}
