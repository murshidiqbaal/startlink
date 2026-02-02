import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/achievements/domain/entities/achievement.dart';
import 'package:startlink/features/achievements/domain/repositories/achievement_repository.dart';

// Events
abstract class AchievementEvent extends Equatable {
  const AchievementEvent();
  @override
  List<Object> get props => [];
}

class FetchAchievements extends AchievementEvent {
  final String userId;
  const FetchAchievements(this.userId);
}

class CheckAchievementRules extends AchievementEvent {
  final String userId;
  final String eventKey;
  const CheckAchievementRules(this.userId, this.eventKey);
}

// States
abstract class AchievementState extends Equatable {
  const AchievementState();
  @override
  List<Object> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoaded extends AchievementState {
  final List<Achievement> achievements;
  final Achievement? justUnlocked; // For Toast triggering

  const AchievementLoaded(this.achievements, {this.justUnlocked});

  @override
  List<Object> get props => [achievements, justUnlocked ?? ''];
}

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementRepository _repository;

  AchievementBloc({required AchievementRepository repository})
    : _repository = repository,
      super(AchievementInitial()) {
    on<FetchAchievements>(_onFetch);
    on<CheckAchievementRules>(_onCheck);
  }

  Future<void> _onFetch(
    FetchAchievements event,
    Emitter<AchievementState> emit,
  ) async {
    try {
      final list = await _repository.getAchievements(event.userId);
      emit(AchievementLoaded(list));
    } catch (_) {}
  }

  Future<void> _onCheck(
    CheckAchievementRules event,
    Emitter<AchievementState> emit,
  ) async {
    // 1. Evaluate rules
    await _repository.evaluateAndAward(event.userId, event.eventKey);

    // 2. Fetch latest list to see if new one was added
    final currentList = (state is AchievementLoaded)
        ? (state as AchievementLoaded).achievements
        : <Achievement>[];
    final newList = await _repository.getAchievements(event.userId);

    // 3. Detect diff for Toast
    Achievement? newUnlock;
    if (newList.length > currentList.length) {
      newUnlock = newList.firstWhere(
        (n) => !currentList.any((c) => c.key == n.key),
        orElse: () => newList.first,
      );
    }

    emit(AchievementLoaded(newList, justUnlocked: newUnlock));
  }
}
