part of 'idea_form_bloc.dart';

enum IdeaFormStatus { initial, loading, success, failure }

class IdeaFormState extends Equatable {
  final String title;
  final String description;
  final String problemStatement;
  final String targetMarket;
  final String currentStage;
  final List<String> skills;
  final bool isPublic;
  final IdeaFormStatus status;
  final String? errorMessage;
  final bool isDraft; // To distinguish between draft and publish success
  final String? initialIdeaId;

  const IdeaFormState({
    this.title = '',
    this.description = '',
    this.problemStatement = '',
    this.targetMarket = '',
    this.currentStage = 'Idea',
    this.skills = const [],
    this.isPublic = true,
    this.status = IdeaFormStatus.initial,
    this.errorMessage,
    this.isDraft = false,
    this.initialIdeaId,
  });

  IdeaFormState copyWith({
    String? title,
    String? description,
    String? problemStatement,
    String? targetMarket,
    String? currentStage,
    List<String>? skills,
    bool? isPublic,
    IdeaFormStatus? status,
    String? errorMessage,
    bool? isDraft,
    String? initialIdeaId,
  }) {
    return IdeaFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      problemStatement: problemStatement ?? this.problemStatement,
      targetMarket: targetMarket ?? this.targetMarket,
      currentStage: currentStage ?? this.currentStage,
      skills: skills ?? this.skills,
      isPublic: isPublic ?? this.isPublic,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      isDraft: isDraft ?? this.isDraft,
      initialIdeaId: initialIdeaId ?? this.initialIdeaId,
    );
  }

  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        problemStatement.isNotEmpty &&
        title.length <= 80;
  }

  bool get isEditing => initialIdeaId != null;

  @override
  List<Object?> get props => [
    title,
    description,
    problemStatement,
    targetMarket,
    currentStage,
    skills,
    isPublic,
    status,
    errorMessage,
    isDraft,
    initialIdeaId,
  ];
}
