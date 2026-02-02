part of 'co_founder_bloc.dart';

enum CoFounderStatus { initial, loading, loaded, error }

class CoFounderState extends Equatable {
  final List<ChatMessage> messages;
  final CoFounderStatus status;
  final String? errorMessage;

  const CoFounderState({
    this.messages = const [],
    this.status = CoFounderStatus.initial,
    this.errorMessage,
  });

  CoFounderState copyWith({
    List<ChatMessage>? messages,
    CoFounderStatus? status,
    String? errorMessage,
  }) {
    return CoFounderState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage];
}
