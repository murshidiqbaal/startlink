part of 'co_founder_bloc.dart';

enum CoFounderStatus { initial, loading, loaded, error }

class CoFounderState extends Equatable {
  final List<ChatMessage> messages;
  final CoFounderStatus status;
  final List<String> insights;
  final List<String> actionItems;
  final List<String> risks;
  final String? errorMessage;

  const CoFounderState({
    this.messages = const [],
    this.status = CoFounderStatus.initial,
    this.insights = const [],
    this.actionItems = const [],
    this.risks = const [],
    this.errorMessage,
  });

  CoFounderState copyWith({
    List<ChatMessage>? messages,
    CoFounderStatus? status,
    List<String>? insights,
    List<String>? actionItems,
    List<String>? risks,
    String? errorMessage,
  }) {
    return CoFounderState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      insights: insights ?? this.insights,
      actionItems: actionItems ?? this.actionItems,
      risks: risks ?? this.risks,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    status,
    insights,
    actionItems,
    risks,
    errorMessage,
  ];
}
