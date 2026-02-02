import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/ai_insights/domain/entities/ai_insight.dart';
import 'package:startlink/features/ai_insights/domain/repositories/ai_insight_repository.dart';

// Events
abstract class AIInsightEvent extends Equatable {
  const AIInsightEvent();
  @override
  List<Object> get props => [];
}

class FetchAIInsight extends AIInsightEvent {
  final String ideaId;
  final String investorId;
  const FetchAIInsight({required this.ideaId, required this.investorId});
  @override
  List<Object> get props => [ideaId, investorId];
}

class TriggerAIAnalysis extends AIInsightEvent {
  final String ideaId;
  final String investorId;
  const TriggerAIAnalysis({required this.ideaId, required this.investorId});
  @override
  List<Object> get props => [ideaId, investorId];
}

// States
abstract class AIInsightState extends Equatable {
  const AIInsightState();
  @override
  List<Object> get props => [];
}

class AIInsightInitial extends AIInsightState {}

class AIInsightLoading extends AIInsightState {}

class AIInsightLoaded extends AIInsightState {
  final AIInsight insight;
  const AIInsightLoaded(this.insight);
  @override
  List<Object> get props => [insight];
}

class AIInsightUnavailable extends AIInsightState {
  // Graceful fallback
  const AIInsightUnavailable();
}

class AIInsightError extends AIInsightState {
  final String message;
  const AIInsightError(this.message);
  @override
  List<Object> get props => [message];
}

class AIInsightBloc extends Bloc<AIInsightEvent, AIInsightState> {
  final AIInsightRepository _repository;

  AIInsightBloc({required AIInsightRepository repository})
    : _repository = repository,
      super(AIInsightInitial()) {
    on<FetchAIInsight>(_onFetch);
    on<TriggerAIAnalysis>(_onAnalyze);
  }

  Future<void> _onAnalyze(
    TriggerAIAnalysis event,
    Emitter<AIInsightState> emit,
  ) async {
    emit(AIInsightLoading());
    try {
      await _repository.analyzeIdea(event.ideaId);
      // Re-fetch after analysis triggers
      add(FetchAIInsight(ideaId: event.ideaId, investorId: event.investorId));
    } catch (e) {
      emit(AIInsightError(e.toString()));
    }
  }

  Future<void> _onFetch(
    FetchAIInsight event,
    Emitter<AIInsightState> emit,
  ) async {
    emit(AIInsightLoading());
    try {
      final insight = await _repository.getInsight(
        event.ideaId,
        event.investorId,
      );

      // If essential data is missing, show unavailable
      if (insight.summary == null && insight.strengths.isEmpty) {
        emit(const AIInsightUnavailable());
      } else {
        emit(AIInsightLoaded(insight));
      }
    } catch (e) {
      // Don't error out, just show unavailable/fallback for AI optionality
      emit(const AIInsightUnavailable());
    }
  }
}
