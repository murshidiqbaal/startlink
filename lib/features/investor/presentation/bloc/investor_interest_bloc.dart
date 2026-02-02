import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/investor/domain/repositories/interest_repository.dart';

// Events
abstract class InvestorInterestEvent extends Equatable {
  const InvestorInterestEvent();
  @override
  List<Object> get props => [];
}

class FetchInterests extends InvestorInterestEvent {
  final String investorId;
  const FetchInterests(this.investorId);
  @override
  List<Object> get props => [investorId];
}

class ExpressInterest extends InvestorInterestEvent {
  final String ideaId;
  final String investorId;
  const ExpressInterest({required this.ideaId, required this.investorId});
  @override
  List<Object> get props => [ideaId, investorId];
}

class BookmarkIdea extends InvestorInterestEvent {
  final String ideaId;
  final String investorId;
  const BookmarkIdea({required this.ideaId, required this.investorId});
  @override
  List<Object> get props => [ideaId, investorId];
}

// States
abstract class InvestorInterestState extends Equatable {
  const InvestorInterestState();
  @override
  List<Object> get props => [];
}

class InvestorInterestInitial extends InvestorInterestState {}

class InvestorInterestLoading extends InvestorInterestState {}

class InvestorInterestLoaded extends InvestorInterestState {
  final List<String> interestedIds;
  final List<String> bookmarkedIds;

  const InvestorInterestLoaded({
    this.interestedIds = const [],
    this.bookmarkedIds = const [],
  });

  bool isInterested(String id) => interestedIds.contains(id);
  bool isBookmarked(String id) => bookmarkedIds.contains(id);

  @override
  List<Object> get props => [interestedIds, bookmarkedIds];
}

class InvestorInterestError extends InvestorInterestState {
  final String message;
  const InvestorInterestError(this.message);
  @override
  List<Object> get props => [message];
}

class InvestorInterestBloc
    extends Bloc<InvestorInterestEvent, InvestorInterestState> {
  final InterestRepository _repository;

  InvestorInterestBloc({required InterestRepository repository})
    : _repository = repository,
      super(InvestorInterestInitial()) {
    on<FetchInterests>(_onFetch);
    on<ExpressInterest>(_onExpressInterest);
    on<BookmarkIdea>(_onBookmark);
  }

  Future<void> _onFetch(
    FetchInterests event,
    Emitter<InvestorInterestState> emit,
  ) async {
    emit(InvestorInterestLoading());
    try {
      final interested = await _repository.getInterestedIdeaIds(
        event.investorId,
      );
      final bookmarked = await _repository.getBookmarkedIdeaIds(
        event.investorId,
      );
      emit(
        InvestorInterestLoaded(
          interestedIds: interested,
          bookmarkedIds: bookmarked,
        ),
      );
    } catch (e) {
      emit(InvestorInterestError(e.toString()));
    }
  }

  Future<void> _onExpressInterest(
    ExpressInterest event,
    Emitter<InvestorInterestState> emit,
  ) async {
    try {
      await _repository.expressInterest(event.ideaId, event.investorId);
      add(FetchInterests(event.investorId)); // Reload
    } catch (e) {
      emit(InvestorInterestError(e.toString()));
    }
  }

  Future<void> _onBookmark(
    BookmarkIdea event,
    Emitter<InvestorInterestState> emit,
  ) async {
    try {
      await _repository.bookmarkIdea(event.ideaId, event.investorId);
      add(FetchInterests(event.investorId)); // Reload
    } catch (e) {
      emit(InvestorInterestError(e.toString()));
    }
  }
}
