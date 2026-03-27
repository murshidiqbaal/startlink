import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/investor/domain/repositories/investor_communication_repository.dart';

// Events
abstract class InvestorDashboardEvent extends Equatable {
  const InvestorDashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadInvestorDashboard extends InvestorDashboardEvent {}

class SearchIdeas extends InvestorDashboardEvent {
  final String query;
  const SearchIdeas(this.query);
  @override
  List<Object?> get props => [query];
}

// States
abstract class InvestorDashboardState extends Equatable {
  const InvestorDashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends InvestorDashboardState {}
class DashboardLoading extends InvestorDashboardState {}
class DashboardLoaded extends InvestorDashboardState {
  final List<Idea> discoverIdeas;
  final List<Idea> recommendedIdeas;
  const DashboardLoaded({
    required this.discoverIdeas,
    required this.recommendedIdeas,
  });
  @override
  List<Object?> get props => [discoverIdeas, recommendedIdeas];
}
class DashboardError extends InvestorDashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class InvestorDashboardBloc extends Bloc<InvestorDashboardEvent, InvestorDashboardState> {
  final InvestorCommunicationRepository _repository;

  InvestorDashboardBloc({required InvestorCommunicationRepository repository})
    : _repository = repository,
      super(DashboardInitial()) {
    on<LoadInvestorDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadInvestorDashboard event,
    Emitter<InvestorDashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final discover = await _repository.fetchIdeas();
      final recommended = await _repository.fetchRecommendedIdeas();
      emit(DashboardLoaded(
        discoverIdeas: discover,
        recommendedIdeas: recommended,
      ));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
