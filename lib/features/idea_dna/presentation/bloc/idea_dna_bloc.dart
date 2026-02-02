import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea_dna/domain/entities/idea_dna.dart';
import 'package:startlink/features/idea_dna/domain/repositories/idea_dna_repository.dart';

part 'idea_dna_event.dart';
part 'idea_dna_state.dart';

class IdeaDnaBloc extends Bloc<IdeaDnaEvent, IdeaDnaState> {
  final IdeaDnaRepository repository;

  IdeaDnaBloc({required this.repository}) : super(IdeaDnaInitial()) {
    on<FetchIdeaDna>(_onFetchIdeaDna);
  }

  Future<void> _onFetchIdeaDna(
    FetchIdeaDna event,
    Emitter<IdeaDnaState> emit,
  ) async {
    emit(IdeaDnaLoading());
    try {
      final dna = await repository.getIdeaDna(event.ideaId);
      emit(IdeaDnaLoaded(dna));
    } catch (e) {
      emit(IdeaDnaError(e.toString()));
    }
  }
}
