import 'package:equatable/equatable.dart';

abstract class IdeaActivityEvent extends Equatable {
  const IdeaActivityEvent();

  @override
  List<Object> get props => [];
}

class LoadIdeaActivity extends IdeaActivityEvent {
  final String ideaId;
  const LoadIdeaActivity(this.ideaId);

  @override
  List<Object> get props => [ideaId];
}
