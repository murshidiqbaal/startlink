part of 'analytics_bloc.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadAnalytics extends AnalyticsEvent {
  final String innovatorId;
  const LoadAnalytics(this.innovatorId);

  @override
  List<Object?> get props => [innovatorId];
}

class RefreshAnalytics extends AnalyticsEvent {
  final String innovatorId;
  const RefreshAnalytics(this.innovatorId);

  @override
  List<Object?> get props => [innovatorId];
}
