import 'package:bloc/bloc.dart';
import 'package:startlink/features/idea/domain/repositories/idea_activity_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/activity/idea_activity_event.dart';
import 'package:startlink/features/idea/presentation/bloc/activity/idea_activity_state.dart';

class IdeaActivityBloc extends Bloc<IdeaActivityEvent, IdeaActivityState> {
  final IdeaActivityRepository _repository;

  IdeaActivityBloc(this._repository) : super(IdeaActivityInitial()) {
    on<LoadIdeaActivity>(_onLoadIdeaActivity);
  }

  Future<void> _onLoadIdeaActivity(
    LoadIdeaActivity event,
    Emitter<IdeaActivityState> emit,
  ) async {
    emit(IdeaActivityLoading());
    try {
      final logs = await _repository.getActivityLogs(event.ideaId);
      emit(IdeaActivityLoaded(logs));
    } catch (e) {
      emit(IdeaActivityError(e.toString()));
    }
  }
}
