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
  final bool isDraft;
  final bool isDeleted;
  final String? initialIdeaId;

  // Additional Metadata
  final String industry;
  final String subIndustry;
  final String businessModel;
  final String monetizationStrategy;
  final String location;
  final double fundingNeeded;
  final double equityOffered;
  final int teamSize;
  final bool lookingForInvestor;
  final bool lookingForCofounder;
  final bool lookingForMentor;
  final String? coverImageUrl;
  final dynamic coverImageFile;
  final String pitchDeckUrl;
  final String demoVideoUrl;
  final String websiteUrl;

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
    this.isDeleted = false,
    this.initialIdeaId,
    this.industry = 'Technology',
    this.subIndustry = '',
    this.businessModel = 'SaaS',
    this.monetizationStrategy = '',
    this.location = '',
    this.fundingNeeded = 0.0,
    this.equityOffered = 0.0,
    this.teamSize = 1,
    this.lookingForInvestor = false,
    this.lookingForCofounder = false,
    this.lookingForMentor = false,
    this.coverImageUrl,
    this.coverImageFile,
    this.pitchDeckUrl = '',
    this.demoVideoUrl = '',
    this.websiteUrl = '',
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
    bool? isDeleted,
    String? initialIdeaId,
    String? industry,
    String? subIndustry,
    String? businessModel,
    String? monetizationStrategy,
    String? location,
    double? fundingNeeded,
    double? equityOffered,
    int? teamSize,
    bool? lookingForInvestor,
    bool? lookingForCofounder,
    bool? lookingForMentor,
    String? coverImageUrl,
    dynamic coverImageFile,
    String? pitchDeckUrl,
    String? demoVideoUrl,
    String? websiteUrl,
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
      isDeleted: isDeleted ?? this.isDeleted,
      initialIdeaId: initialIdeaId ?? this.initialIdeaId,
      industry: industry ?? this.industry,
      subIndustry: subIndustry ?? this.subIndustry,
      businessModel: businessModel ?? this.businessModel,
      monetizationStrategy: monetizationStrategy ?? this.monetizationStrategy,
      location: location ?? this.location,
      fundingNeeded: fundingNeeded ?? this.fundingNeeded,
      equityOffered: equityOffered ?? this.equityOffered,
      teamSize: teamSize ?? this.teamSize,
      lookingForInvestor: lookingForInvestor ?? this.lookingForInvestor,
      lookingForCofounder: lookingForCofounder ?? this.lookingForCofounder,
      lookingForMentor: lookingForMentor ?? this.lookingForMentor,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImageFile: coverImageFile ?? this.coverImageFile,
      pitchDeckUrl: pitchDeckUrl ?? this.pitchDeckUrl,
      demoVideoUrl: demoVideoUrl ?? this.demoVideoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
    );
  }

  bool get isValid => title.isNotEmpty && description.isNotEmpty;

  bool get isContentEmpty =>
      title.trim().isEmpty &&
      description.trim().isEmpty &&
      problemStatement.trim().isEmpty;

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
    isDeleted,
    initialIdeaId,
    industry,
    subIndustry,
    businessModel,
    monetizationStrategy,
    location,
    fundingNeeded,
    equityOffered,
    teamSize,
    lookingForInvestor,
    lookingForCofounder,
    lookingForMentor,
    coverImageUrl,
    coverImageFile,
    pitchDeckUrl,
    demoVideoUrl,
    websiteUrl,
  ];
}
