part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsData data;
  const AnalyticsLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
