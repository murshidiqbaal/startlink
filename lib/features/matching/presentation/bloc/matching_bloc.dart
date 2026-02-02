import 'package:bloc/bloc.dart';
import 'package:startlink/features/matching/domain/repositories/matching_repository.dart';
import 'package:startlink/features/matching/presentation/bloc/matching_event.dart';
import 'package:startlink/features/matching/presentation/bloc/matching_state.dart';

class MatchingBloc extends Bloc<MatchingEvent, MatchingState> {
  final MatchingRepository _repository;

  MatchingBloc({required MatchingRepository repository})
    : _repository = repository,
      super(MatchingInitial()) {
    on<LoadMatches>(_onLoadMatches);
  }

  Future<void> _onLoadMatches(
    LoadMatches event,
    Emitter<MatchingState> emit,
  ) async {
    emit(MatchingLoading());
    try {
      // 1. Try to fetch existing matches
      var matches = await _repository.getMatchesForIdea(event.idea.id);

      // 2. If no matches found or very few, trigger generation
      if (matches.isEmpty) {
        await _repository.generateMatchesForIdea(event.idea);
        // 3. Fetch again
        matches = await _repository.getMatchesForIdea(event.idea.id);
      }

      // Group by role
      final mentors = matches.where((m) => m.role == 'Mentor').toList();
      final collaborators = matches.where((m) => m.role != 'Mentor').toList();

      emit(MatchingLoaded(mentors: mentors, collaborators: collaborators));
    } catch (e) {
      emit(MatchingError(e.toString()));
    }
  }
}
