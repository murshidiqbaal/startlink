part of 'idea_form_bloc.dart';

abstract class IdeaFormEvent extends Equatable {
  const IdeaFormEvent();

  @override
  List<Object> get props => [];
}

class InitializeForm extends IdeaFormEvent {
  final Idea? idea;
  const InitializeForm(this.idea);

  @override
  List<Object> get props => [if (idea != null) idea!];
}

class TitleChanged extends IdeaFormEvent {
  final String title;
  const TitleChanged(this.title);

  @override
  List<Object> get props => [title];
}

class DescriptionChanged extends IdeaFormEvent {
  final String description;
  const DescriptionChanged(this.description);

  @override
  List<Object> get props => [description];
}

class ProblemStatementChanged extends IdeaFormEvent {
  final String problemStatement;
  const ProblemStatementChanged(this.problemStatement);

  @override
  List<Object> get props => [problemStatement];
}

class TargetMarketChanged extends IdeaFormEvent {
  final String targetMarket;
  const TargetMarketChanged(this.targetMarket);

  @override
  List<Object> get props => [targetMarket];
}

class CurrentStageChanged extends IdeaFormEvent {
  final String currentStage;
  const CurrentStageChanged(this.currentStage);

  @override
  List<Object> get props => [currentStage];
}

class SkillsChanged extends IdeaFormEvent {
  final List<String> skills;
  const SkillsChanged(this.skills);

  @override
  List<Object> get props => [skills];
}

class VisibilityChanged extends IdeaFormEvent {
  final bool isPublic;
  const VisibilityChanged(this.isPublic);

  @override
  List<Object> get props => [isPublic];
}

class SaveDraft extends IdeaFormEvent {}

class PublishIdea extends IdeaFormEvent {}
