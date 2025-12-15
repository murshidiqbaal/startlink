import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';

// Events
abstract class IdeaEvent extends Equatable {
  const IdeaEvent();
  @override
  List<Object> get props => [];
}

class FetchIdeas extends IdeaEvent {}

class RefreshIdeas extends IdeaEvent {}

// States
abstract class IdeaState extends Equatable {
  const IdeaState();
  @override
  List<Object> get props => [];
}

class IdeaInitial extends IdeaState {}

class IdeaLoading extends IdeaState {}

class IdeaLoaded extends IdeaState {
  final List<Idea> ideas;
  const IdeaLoaded(this.ideas);
  @override
  List<Object> get props => [ideas];
}

class IdeaError extends IdeaState {
  final String message;
  const IdeaError(this.message);
  @override
  List<Object> get props => [message];
}

// BLoC
class IdeaBloc extends Bloc<IdeaEvent, IdeaState> {
  final IdeaRepository _ideaRepository;

  IdeaBloc({required IdeaRepository ideaRepository})
    : _ideaRepository = ideaRepository,
      super(IdeaInitial()) {
    on<FetchIdeas>(_onFetchIdeas);
    on<RefreshIdeas>(_onRefreshIdeas);
  }

  Future<void> _onFetchIdeas(FetchIdeas event, Emitter<IdeaState> emit) async {
    emit(IdeaLoading());
    try {
      final ideas = await _ideaRepository.fetchMyIdeas();
      emit(IdeaLoaded(ideas));
    } catch (e) {
      emit(IdeaError(e.toString()));
    }
  }

  Future<void> _onRefreshIdeas(
    RefreshIdeas event,
    Emitter<IdeaState> emit,
  ) async {
    try {
      final ideas = await _ideaRepository.fetchMyIdeas();
      emit(IdeaLoaded(ideas));
    } catch (e) {
      emit(IdeaError(e.toString()));
    }
  }
}
