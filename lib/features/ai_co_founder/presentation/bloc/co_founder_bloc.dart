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
    emit(
      state.copyWith(
        messages: List.from(state.messages)..add(userMsg),
        status: CoFounderStatus.loading,
      ),
    );

    try {
      // 2. Call AI
      final aiResponseText = await repository.sendMessage(
        event.message,
        contextId: event.contextId,
      );

      final aiMsg = ChatMessage(
        id: _uuid.v4(),
        text: aiResponseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      // 3. Add AI Response
      emit(
        state.copyWith(
          messages: List.from(state.messages)..add(aiMsg),
          status: CoFounderStatus.loaded,
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
