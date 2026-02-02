import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/pitch_health/data/repositories/pitch_health_repository.dart';
import 'package:startlink/features/pitch_health/domain/entities/pitch_score.dart';
import 'package:stream_transform/stream_transform.dart';

part 'pitch_health_event.dart';
part 'pitch_health_state.dart';

const _debounceDuration = Duration(milliseconds: 800);

EventTransformer<E> _debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class PitchHealthBloc extends Bloc<PitchHealthEvent, PitchHealthState> {
  final PitchHealthRepository repository;

  PitchHealthBloc({required this.repository}) : super(PitchHealthInitial()) {
    on<AnalyzePitch>(
      _onAnalyzePitch,
      transformer: _debounce(_debounceDuration),
    );
  }

  Future<void> _onAnalyzePitch(
    AnalyzePitch event,
    Emitter<PitchHealthState> emit,
  ) async {
    if (event.description.length < 20) {
      emit(PitchHealthInitial());
      return;
    }

    emit(PitchHealthLoading());
    try {
      final score = await repository.analyzePitch(
        event.title,
        event.description,
      );
      emit(PitchHealthLoaded(score));
    } catch (e) {
      emit(const PitchHealthError("Could not analyze"));
    }
  }
}
