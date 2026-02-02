import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/aura/domain/entities/aura_activity.dart';
import 'package:startlink/features/aura/domain/repositories/aura_repository.dart';

// Events
abstract class AuraEvent extends Equatable {
  const AuraEvent();
  @override
  List<Object> get props => [];
}

class FetchAura extends AuraEvent {
  final String userId;
  const FetchAura(this.userId);
}

class AwardAura extends AuraEvent {
  final String userId;
  final int points;
  final String reason;
  const AwardAura({
    required this.userId,
    required this.points,
    required this.reason,
  });
}

// States
abstract class AuraState extends Equatable {
  const AuraState();
  @override
  List<Object> get props => [];
}

class AuraInitial extends AuraState {}

class AuraLoading extends AuraState {}

class AuraLoaded extends AuraState {
  final int totalPoints;
  final List<AuraActivity> history;
  final Map<String, dynamic>? weeklySummary;

  const AuraLoaded(this.totalPoints, this.history, {this.weeklySummary});

  @override
  List<Object> get props => [totalPoints, history, weeklySummary ?? {}];
}

class AuraError extends AuraState {
  final String message;
  const AuraError(this.message);
  @override
  List<Object> get props => [message];
}

class AuraBloc extends Bloc<AuraEvent, AuraState> {
  final AuraRepository _repository;

  AuraBloc({required AuraRepository repository})
    : _repository = repository,
      super(AuraInitial()) {
    on<FetchAura>(_onFetch);
    on<AwardAura>(_onAward);
  }

  Future<void> _onFetch(FetchAura event, Emitter<AuraState> emit) async {
    emit(AuraLoading());
    try {
      final total = await _repository.getTotalAura(event.userId);
      // Run history and summary fetch in parallel
      final results = await Future.wait([
        _repository.getHistory(event.userId),
        _repository.getWeeklySummary(event.userId),
      ]);

      final history = results[0] as List<AuraActivity>;
      final summary = results[1] as Map<String, dynamic>?;

      emit(AuraLoaded(total, history, weeklySummary: summary));
    } catch (e) {
      emit(AuraError(e.toString()));
    }
  }

  Future<void> _onAward(AwardAura event, Emitter<AuraState> emit) async {
    try {
      await _repository.awardPoints(
        userId: event.userId,
        points: event.points,
        reason: event.reason,
      );
      // Refresh
      add(FetchAura(event.userId));
    } catch (e) {
      // Silent fail or snackbar trigger logic
    }
  }
}
