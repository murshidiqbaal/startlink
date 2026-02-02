part of 'co_founder_bloc.dart';

abstract class CoFounderEvent extends Equatable {
  const CoFounderEvent();
  @override
  List<Object> get props => [];
}

class SendMessage extends CoFounderEvent {
  final String message;
  final String? contextId;

  const SendMessage(this.message, {this.contextId});

  @override
  List<Object> get props => [message, if (contextId != null) contextId!];
}
