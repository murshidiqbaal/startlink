import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/analytics_data.dart';
import '../../domain/repositories/analytics_repository.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsRepository _repository;

  AnalyticsBloc({required AnalyticsRepository repository})
      : _repository = repository,
        super(AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<RefreshAnalytics>(_onRefreshAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final data = await _repository.fetchInnovatorAnalytics(event.innovatorId);
      emit(AnalyticsLoaded(data));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      final data = await _repository.fetchInnovatorAnalytics(event.innovatorId);
      emit(AnalyticsLoaded(data));
    } catch (e) {
      // Don't emit error for background refresh to avoid UI flickering if it was already loaded
    }
  }
}
