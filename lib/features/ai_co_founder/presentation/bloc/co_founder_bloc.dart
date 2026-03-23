import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/ai_co_founder/domain/entities/chat_message.dart';
import 'package:startlink/features/ai_co_founder/domain/repositories/co_founder_repository.dart';
import 'package:uuid/uuid.dart';

part 'co_founder_event.dart';
part 'co_founder_state.dart';

class CoFounderBloc extends Bloc<CoFounderEvent, CoFounderState> {
  final CoFounderRepository repository;
  final _uuid = const Uuid();

  CoFounderBloc({required this.repository}) : super(const CoFounderState()) {
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<CoFounderState> emit,
  ) async {
    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: event.message,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    // 1. Add User Message immediately
    // Note: We create a new list including the user message to pass as history
    final currentMessages = List<ChatMessage>.from(state.messages)
      ..add(userMsg);

    emit(
      state.copyWith(
        messages: currentMessages,
        status: CoFounderStatus.loading,
      ),
    );

    try {
      // 2. Call AI with history
      final response = await repository.sendMessage(
        event.message,
        contextId: event.contextId,
        history:
            state.messages, // Pass the messages including the new user message
      );

      final aiMsg = ChatMessage(
        id: _uuid.v4(),
        text: response.reply,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      // 3. Add AI Response and update structured data
      // We append new insights/actions to the existing ones or replace them?
      // Since it's a "Co-Founder" giving advice on the *current* state, let's append unique ones or just replace if it's a new analysis.
      // For now, let's add them to the top or just replace list if meaningful.
      // Actually, typically we want to accumulate insights.

      final updatedInsights = List<String>.from(state.insights)
        ..addAll(response.insights);
      final updatedActions = List<String>.from(state.actionItems)
        ..addAll(response.actionItems);
      final updatedRisks = List<String>.from(state.risks)
        ..addAll(response.risks);

      emit(
        state.copyWith(
          messages: List.from(state.messages)..add(aiMsg),
          status: CoFounderStatus.loaded,
          insights: updatedInsights.toSet().toList(), // Deduplicate
          actionItems: updatedActions.toSet().toList(),
          risks: updatedRisks.toSet().toList(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CoFounderStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
