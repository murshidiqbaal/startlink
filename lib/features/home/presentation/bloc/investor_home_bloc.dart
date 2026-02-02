import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';

// Events
abstract class InvestorHomeEvent extends Equatable {
  const InvestorHomeEvent();
  @override
  List<Object> get props => [];
}

class FetchInvestorFeed extends InvestorHomeEvent {}

// States
abstract class InvestorHomeState extends Equatable {
  const InvestorHomeState();
  @override
  List<Object> get props => [];
}

class InvestorHomeInitial extends InvestorHomeState {}

class InvestorHomeLoading extends InvestorHomeState {}

class InvestorHomeLoaded extends InvestorHomeState {
  final List<Idea> ideas;
  const InvestorHomeLoaded(this.ideas);
  @override
  List<Object> get props => [ideas];
}

class InvestorHomeError extends InvestorHomeState {
  final String message;
  const InvestorHomeError(this.message);
  @override
  List<Object> get props => [message];
}

class InvestorHomeBloc extends Bloc<InvestorHomeEvent, InvestorHomeState> {
  final IdeaRepository _ideaRepository;

  InvestorHomeBloc({required IdeaRepository ideaRepository})
    : _ideaRepository = ideaRepository,
      super(InvestorHomeInitial()) {
    on<FetchInvestorFeed>(_onFetchFeed);
  }

  Future<void> _onFetchFeed(
    FetchInvestorFeed event,
    Emitter<InvestorHomeState> emit,
  ) async {
    emit(InvestorHomeLoading());
    try {
      final ideas = await _ideaRepository.fetchPublishedIdeas();
      // In future: Filter by 'Fundable' criteria or specific user preferences
      emit(InvestorHomeLoaded(ideas));
    } catch (e) {
      emit(InvestorHomeError(e.toString()));
    }
  }
}
