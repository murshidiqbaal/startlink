import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';

part 'idea_form_event.dart';
part 'idea_form_state.dart';

class IdeaFormBloc extends Bloc<IdeaFormEvent, IdeaFormState> {
  final IdeaRepository _ideaRepository;

  IdeaFormBloc({required IdeaRepository ideaRepository})
    : _ideaRepository = ideaRepository,
      super(const IdeaFormState()) {
    on<InitializeForm>(_onInitializeForm);
    on<TitleChanged>(_onTitleChanged);
    on<DescriptionChanged>(_onDescriptionChanged);
    on<ProblemStatementChanged>(_onProblemStatementChanged);
    on<TargetMarketChanged>(_onTargetMarketChanged);
    on<CurrentStageChanged>(_onCurrentStageChanged);
    on<SkillsChanged>(_onSkillsChanged);
    on<VisibilityChanged>(_onVisibilityChanged);
    on<SaveDraft>(_onSaveDraft);
    on<PublishIdea>(_onPublishIdea);
  }

  void _onInitializeForm(InitializeForm event, Emitter<IdeaFormState> emit) {
    if (event.idea != null) {
      final idea = event.idea!;
      emit(
        state.copyWith(
          title: idea.title,
          description: idea.description,
          problemStatement: idea.problemStatement,
          targetMarket: idea.targetMarket,
          currentStage: idea.currentStage,
          skills: idea.tags,
          isPublic: idea.isPublic,
          status: IdeaFormStatus.initial,
          initialIdeaId: idea.id,
        ),
      );
    }
  }

  void _onTitleChanged(TitleChanged event, Emitter<IdeaFormState> emit) {
    emit(state.copyWith(title: event.title, status: IdeaFormStatus.initial));
  }

  void _onDescriptionChanged(
    DescriptionChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        description: event.description,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onProblemStatementChanged(
    ProblemStatementChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        problemStatement: event.problemStatement,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onTargetMarketChanged(
    TargetMarketChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        targetMarket: event.targetMarket,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onCurrentStageChanged(
    CurrentStageChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        currentStage: event.currentStage,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onSkillsChanged(SkillsChanged event, Emitter<IdeaFormState> emit) {
    emit(state.copyWith(skills: event.skills, status: IdeaFormStatus.initial));
  }

  void _onVisibilityChanged(
    VisibilityChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(isPublic: event.isPublic, status: IdeaFormStatus.initial),
    );
  }

  Future<void> _onSaveDraft(
    SaveDraft event,
    Emitter<IdeaFormState> emit,
  ) async {
    emit(state.copyWith(status: IdeaFormStatus.loading));
    try {
      final idea = Idea(
        id: state.initialIdeaId ?? '',
        title: state.title,
        description: state.description,
        ownerId: '', // Handled by Repository
        problemStatement: state.problemStatement,
        targetMarket: state.targetMarket,
        currentStage: state.currentStage,
        isPublic: state.isPublic,
        tags: state.skills,
        status: 'Draft',
      );

      if (state.isEditing) {
        await _ideaRepository.updateIdea(idea);
      } else {
        await _ideaRepository.createIdea(idea);
      }

      emit(state.copyWith(status: IdeaFormStatus.success, isDraft: true));
    } catch (e) {
      emit(
        state.copyWith(
          status: IdeaFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPublishIdea(
    PublishIdea event,
    Emitter<IdeaFormState> emit,
  ) async {
    if (!state.isValid) {
      emit(
        state.copyWith(
          status: IdeaFormStatus.failure,
          errorMessage: 'Please fill in all mandatory fields.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: IdeaFormStatus.loading));
    try {
      final idea = Idea(
        id: state.initialIdeaId ?? '',
        title: state.title,
        description: state.description,
        ownerId: '', // Handled by Repository
        problemStatement: state.problemStatement,
        targetMarket: state.targetMarket,
        currentStage: state.currentStage,
        isPublic: state.isPublic,
        tags: state.skills,
        status: 'Published',
      );

      if (state.isEditing) {
        await _ideaRepository.updateIdea(idea);
      } else {
        await _ideaRepository.createIdea(idea);
      }

      emit(state.copyWith(status: IdeaFormStatus.success, isDraft: false));
    } catch (e) {
      emit(
        state.copyWith(
          status: IdeaFormStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
