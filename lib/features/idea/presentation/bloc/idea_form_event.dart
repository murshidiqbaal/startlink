part of 'idea_form_bloc.dart';

abstract class IdeaFormEvent extends Equatable {
  const IdeaFormEvent();

  @override
  List<Object?> get props => [];
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

class IndustryChanged extends IdeaFormEvent {
  final String industry;
  const IndustryChanged(this.industry);

  @override
  List<Object> get props => [industry];
}

class SubIndustryChanged extends IdeaFormEvent {
  final String subIndustry;
  const SubIndustryChanged(this.subIndustry);

  @override
  List<Object> get props => [subIndustry];
}

class BusinessModelChanged extends IdeaFormEvent {
  final String businessModel;
  const BusinessModelChanged(this.businessModel);

  @override
  List<Object> get props => [businessModel];
}

class MonetizationStrategyChanged extends IdeaFormEvent {
  final String monetizationStrategy;
  const MonetizationStrategyChanged(this.monetizationStrategy);

  @override
  List<Object> get props => [monetizationStrategy];
}

class LocationChanged extends IdeaFormEvent {
  final String location;
  const LocationChanged(this.location);

  @override
  List<Object> get props => [location];
}

class FundingNeededChanged extends IdeaFormEvent {
  final double fundingNeeded;
  const FundingNeededChanged(this.fundingNeeded);

  @override
  List<Object> get props => [fundingNeeded];
}

class EquityOfferedChanged extends IdeaFormEvent {
  final double equityOffered;
  const EquityOfferedChanged(this.equityOffered);

  @override
  List<Object> get props => [equityOffered];
}

class TeamSizeChanged extends IdeaFormEvent {
  final int teamSize;
  const TeamSizeChanged(this.teamSize);

  @override
  List<Object> get props => [teamSize];
}

class LookingForInvestorChanged extends IdeaFormEvent {
  final bool lookingForInvestor;
  const LookingForInvestorChanged(this.lookingForInvestor);

  @override
  List<Object> get props => [lookingForInvestor];
}

class LookingForCofounderChanged extends IdeaFormEvent {
  final bool lookingForCofounder;
  const LookingForCofounderChanged(this.lookingForCofounder);

  @override
  List<Object> get props => [lookingForCofounder];
}

class LookingForMentorChanged extends IdeaFormEvent {
  final bool lookingForMentor;
  const LookingForMentorChanged(this.lookingForMentor);

  @override
  List<Object> get props => [lookingForMentor];
}

class CoverImageChanged extends IdeaFormEvent {
  final String? coverImageUrl;
  const CoverImageChanged(this.coverImageUrl);

  @override
  List<Object?> get props => [coverImageUrl];
}

class PitchDeckUrlChanged extends IdeaFormEvent {
  final String pitchDeckUrl;
  const PitchDeckUrlChanged(this.pitchDeckUrl);

  @override
  List<Object> get props => [pitchDeckUrl];
}

class DemoVideoUrlChanged extends IdeaFormEvent {
  final String demoVideoUrl;
  const DemoVideoUrlChanged(this.demoVideoUrl);

  @override
  List<Object> get props => [demoVideoUrl];
}

class WebsiteUrlChanged extends IdeaFormEvent {
  final String websiteUrl;
  const WebsiteUrlChanged(this.websiteUrl);

  @override
  List<Object> get props => [websiteUrl];
}

class CoverImageFileChanged extends IdeaFormEvent {
  final dynamic file;
  const CoverImageFileChanged(this.file);

  @override
  List<Object?> get props => [file];
}

class SaveDraft extends IdeaFormEvent {}

class PublishIdea extends IdeaFormEvent {}

class DeleteIdea extends IdeaFormEvent {}
