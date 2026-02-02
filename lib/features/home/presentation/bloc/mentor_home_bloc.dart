import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';

// Events
abstract class MentorHomeEvent extends Equatable {
  const MentorHomeEvent();
  @override
  List<Object> get props => [];
}

class FetchMentorFeed extends MentorHomeEvent {}

// States
abstract class MentorHomeState extends Equatable {
  const MentorHomeState();
  @override
  List<Object> get props => [];
}

class MentorHomeInitial extends MentorHomeState {}

class MentorHomeLoading extends MentorHomeState {}

class MentorHomeLoaded extends MentorHomeState {
  final List<Idea> ideas;
  const MentorHomeLoaded(this.ideas);
  @override
  List<Object> get props => [ideas];
}

class MentorHomeError extends MentorHomeState {
  final String message;
  const MentorHomeError(this.message);
  @override
  List<Object> get props => [message];
}

class MentorHomeBloc extends Bloc<MentorHomeEvent, MentorHomeState> {
  final IdeaRepository _ideaRepository;

  MentorHomeBloc({required IdeaRepository ideaRepository})
    : _ideaRepository = ideaRepository,
      super(MentorHomeInitial()) {
    on<FetchMentorFeed>(_onFetchFeed);
  }

  Future<void> _onFetchFeed(
    FetchMentorFeed event,
    Emitter<MentorHomeState> emit,
  ) async {
    emit(MentorHomeLoading());
    try {
      final ideas = await _ideaRepository.fetchPublishedIdeas();
      emit(MentorHomeLoaded(ideas));
    } catch (e) {
      emit(MentorHomeError(e.toString()));
    }
  }
}
