import 'package:bloc/bloc.dart';
import 'package:startlink/features/compass/domain/repositories/compass_repository.dart';
import 'package:startlink/features/compass/presentation/bloc/compass_event.dart';
import 'package:startlink/features/compass/presentation/bloc/compass_state.dart';

class CompassBloc extends Bloc<CompassEvent, CompassState> {
  final CompassRepository _repository;

  CompassBloc({required CompassRepository repository})
    : _repository = repository,
      super(CompassInitial()) {
    on<LoadCompass>(_onLoadCompass);
    // Ideally listen to other blocs like ProfileBloc, IdeaBloc but for MVP we load directly.
  }

  Future<void> _onLoadCompass(
    LoadCompass event,
    Emitter<CompassState> emit,
  ) async {
    emit(CompassLoading());
    try {
      final recs = await _repository.getRecommendations(event.profileId);
      emit(CompassLoaded(recs));
    } catch (e) {
      emit(CompassError(e.toString()));
    }
  }
}
