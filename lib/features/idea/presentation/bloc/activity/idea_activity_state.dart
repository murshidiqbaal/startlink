import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea_activity_log.dart';

abstract class IdeaActivityState extends Equatable {
  const IdeaActivityState();

  @override
  List<Object> get props => [];
}

class IdeaActivityInitial extends IdeaActivityState {}

class IdeaActivityLoading extends IdeaActivityState {}

class IdeaActivityLoaded extends IdeaActivityState {
  final List<IdeaActivityLog> logs;

  const IdeaActivityLoaded(this.logs);

  @override
  List<Object> get props => [logs];
}

class IdeaActivityError extends IdeaActivityState {
  final String message;

  const IdeaActivityError(this.message);

  @override
  List<Object> get props => [message];
}
