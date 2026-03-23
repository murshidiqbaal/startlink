import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/features/idea/data/repositories/idea_activity_repository_impl.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/domain/services/idea_activity_logger.dart';

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
    on<IndustryChanged>(_onIndustryChanged);
    on<SubIndustryChanged>(_onSubIndustryChanged);
    on<BusinessModelChanged>(_onBusinessModelChanged);
    on<MonetizationStrategyChanged>(_onMonetizationStrategyChanged);
    on<LocationChanged>(_onLocationChanged);
    on<FundingNeededChanged>(_onFundingNeededChanged);
    on<EquityOfferedChanged>(_onEquityOfferedChanged);
    on<TeamSizeChanged>(_onTeamSizeChanged);
    on<LookingForInvestorChanged>(_onLookingForInvestorChanged);
    on<LookingForCofounderChanged>(_onLookingForCofounderChanged);
    on<LookingForMentorChanged>(_onLookingForMentorChanged);
    on<CoverImageChanged>(_onCoverImageChanged);
    on<PitchDeckUrlChanged>(_onPitchDeckUrlChanged);
    on<DemoVideoUrlChanged>(_onDemoVideoUrlChanged);
    on<WebsiteUrlChanged>(_onWebsiteUrlChanged);
    on<CoverImageFileChanged>(_onCoverImageFileChanged);
    on<SaveDraft>(_onSaveDraft);
    on<PublishIdea>(_onPublishIdea);
    on<DeleteIdea>(_onDeleteIdea);
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
          industry: idea.industry ?? 'Technology',
          subIndustry: idea.subIndustry ?? '',
          businessModel: idea.businessModel ?? 'SaaS',
          monetizationStrategy: idea.monetizationStrategy ?? '',
          location: idea.location ?? '',
          fundingNeeded: idea.fundingNeeded ?? 0.0,
          equityOffered: idea.equityOffered ?? 0.0,
          teamSize: idea.teamSize,
          lookingForInvestor: idea.lookingForInvestor,
          lookingForCofounder: idea.lookingForCofounder,
          lookingForMentor: idea.lookingForMentor,
          coverImageUrl: idea.coverImageUrl,
          pitchDeckUrl: idea.pitchDeckUrl ?? '',
          demoVideoUrl: idea.demoVideoUrl ?? '',
          websiteUrl: idea.websiteUrl ?? '',
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

  void _onIndustryChanged(IndustryChanged event, Emitter<IdeaFormState> emit) {
    emit(
      state.copyWith(industry: event.industry, status: IdeaFormStatus.initial),
    );
  }

  void _onSubIndustryChanged(
    SubIndustryChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        subIndustry: event.subIndustry,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onBusinessModelChanged(
    BusinessModelChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        businessModel: event.businessModel,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onMonetizationStrategyChanged(
    MonetizationStrategyChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        monetizationStrategy: event.monetizationStrategy,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onLocationChanged(LocationChanged event, Emitter<IdeaFormState> emit) {
    emit(
      state.copyWith(location: event.location, status: IdeaFormStatus.initial),
    );
  }

  void _onFundingNeededChanged(
    FundingNeededChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        fundingNeeded: event.fundingNeeded,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onEquityOfferedChanged(
    EquityOfferedChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        equityOffered: event.equityOffered,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onTeamSizeChanged(TeamSizeChanged event, Emitter<IdeaFormState> emit) {
    emit(
      state.copyWith(teamSize: event.teamSize, status: IdeaFormStatus.initial),
    );
  }

  void _onLookingForInvestorChanged(
    LookingForInvestorChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        lookingForInvestor: event.lookingForInvestor,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onLookingForCofounderChanged(
    LookingForCofounderChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        lookingForCofounder: event.lookingForCofounder,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onLookingForMentorChanged(
    LookingForMentorChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        lookingForMentor: event.lookingForMentor,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onCoverImageChanged(
    CoverImageChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        coverImageUrl: event.coverImageUrl,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onPitchDeckUrlChanged(
    PitchDeckUrlChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        pitchDeckUrl: event.pitchDeckUrl,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onDemoVideoUrlChanged(
    DemoVideoUrlChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        demoVideoUrl: event.demoVideoUrl,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onWebsiteUrlChanged(
    WebsiteUrlChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        websiteUrl: event.websiteUrl,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  void _onCoverImageFileChanged(
    CoverImageFileChanged event,
    Emitter<IdeaFormState> emit,
  ) {
    emit(
      state.copyWith(
        coverImageFile: event.file,
        status: IdeaFormStatus.initial,
      ),
    );
  }

  Future<void> _onSaveDraft(
    SaveDraft event,
    Emitter<IdeaFormState> emit,
  ) async {
    if (state.isContentEmpty) {
      emit(
        state.copyWith(
          status: IdeaFormStatus.initial, // Reset status
          errorMessage: 'Cannot save an empty idea.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: IdeaFormStatus.loading));
    try {
      String? finalCoverUrl = state.coverImageUrl;

      // 1. Upload cover image if needed
      if (state.coverImageFile != null) {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId != null) {
          final url = await _ideaRepository.uploadCoverImage(
            state.coverImageFile,
            userId,
          );
          if (url != null) finalCoverUrl = url;
        }
      }

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
        industry: state.industry,
        subIndustry: state.subIndustry,
        businessModel: state.businessModel,
        monetizationStrategy: state.monetizationStrategy,
        location: state.location,
        fundingNeeded: state.fundingNeeded,
        equityOffered: state.equityOffered,
        teamSize: state.teamSize,
        lookingForInvestor: state.lookingForInvestor,
        lookingForCofounder: state.lookingForCofounder,
        lookingForMentor: state.lookingForMentor,
        coverImageUrl: finalCoverUrl,
        pitchDeckUrl: state.pitchDeckUrl,
        demoVideoUrl: state.demoVideoUrl,
        websiteUrl: state.websiteUrl,
      );

      if (state.isEditing) {
        await _ideaRepository.updateIdea(idea);
      } else {
        final newId = await _ideaRepository.createIdea(idea);
        final logger = IdeaActivityLogger(IdeaActivityRepositoryImpl());
        await logger.logIdeaCreated(newId, idea.title);
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
      String? finalCoverUrl = state.coverImageUrl;

      // 1. Upload cover image if needed
      if (state.coverImageFile != null) {
        final userId = SupabaseService.client.auth.currentUser?.id;
        if (userId != null) {
          final url = await _ideaRepository.uploadCoverImage(
            state.coverImageFile,
            userId,
          );
          if (url != null) finalCoverUrl = url;
        }
      }

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
        industry: state.industry,
        subIndustry: state.subIndustry,
        businessModel: state.businessModel,
        monetizationStrategy: state.monetizationStrategy,
        location: state.location,
        fundingNeeded: state.fundingNeeded,
        equityOffered: state.equityOffered,
        teamSize: state.teamSize,
        lookingForInvestor: state.lookingForInvestor,
        lookingForCofounder: state.lookingForCofounder,
        lookingForMentor: state.lookingForMentor,
        coverImageUrl: finalCoverUrl,
        pitchDeckUrl: state.pitchDeckUrl,
        demoVideoUrl: state.demoVideoUrl,
        websiteUrl: state.websiteUrl,
      );

      if (state.isEditing) {
        await _ideaRepository.updateIdea(idea);
      } else {
        final newId = await _ideaRepository.createIdea(idea);
        final logger = IdeaActivityLogger(IdeaActivityRepositoryImpl());
        await logger.logIdeaCreated(newId, idea.title);
        await logger.logIdeaPublished(newId);
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

  Future<void> _onDeleteIdea(
    DeleteIdea event,
    Emitter<IdeaFormState> emit,
  ) async {
    if (!state.isEditing || state.initialIdeaId == null) {
      return;
    }

    emit(state.copyWith(status: IdeaFormStatus.loading));
    try {
      await _ideaRepository.deleteIdea(state.initialIdeaId!);
      emit(state.copyWith(status: IdeaFormStatus.success, isDeleted: true));
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
