import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/presentation/widgets/startlink_button.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_form_bloc.dart';
import 'package:startlink/features/pitch_health/presentation/widgets/pitch_health_meter.dart';

class IdeaPostScreen extends StatelessWidget {
  final Idea? idea;
  const IdeaPostScreen({super.key, this.idea});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          IdeaFormBloc(ideaRepository: context.read<IdeaRepository>())
            ..add(InitializeForm(idea)),
      child: _ProgressiveIdeaForm(idea: idea),
    );
  }
}

class _ProgressiveIdeaForm extends StatefulWidget {
  final Idea? idea;
  const _ProgressiveIdeaForm({this.idea});

  @override
  State<_ProgressiveIdeaForm> createState() => _ProgressiveIdeaFormState();
}

class _ProgressiveIdeaFormState extends State<_ProgressiveIdeaForm> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final ScrollController _scrollController = ScrollController();

  // Field Controllers
  final _skillController = TextEditingController();
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.idea?.title ?? '');
    _descController = TextEditingController(
      text: widget.idea?.description ?? '',
    );

    // Sync with Bloc on change
    _titleController.addListener(() {
      context.read<IdeaFormBloc>().add(TitleChanged(_titleController.text));
    });
    _descController.addListener(() {
      context.read<IdeaFormBloc>().add(
        DescriptionChanged(_descController.text),
      );
    });
  }

  @override
  void dispose() {
    _skillController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
    // Smooth scroll to next step
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.offset + 200,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IdeaFormBloc, IdeaFormState>(
      listener: (context, state) {
        if (state.status == IdeaFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'),
              backgroundColor: AppColors.rose,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state.status == IdeaFormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    state.isDraft
                        ? 'Saved to Lab'
                        : 'Idea Created Successfully',
                  ),
                ],
              ),
              backgroundColor: AppColors.emerald,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(context, state),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildProgressIndicator(context),
                        const SizedBox(height: 24),
                        _buildStep(
                          context: context,
                          index: 0,
                          title: 'The Spark',
                          subtitle: 'What is your idea in a nutshell?',
                          isActive: _currentStep == 0,
                          isCompleted: _currentStep > 0,
                          content: _buildBasicsSection(context),
                        ),
                        const SizedBox(height: 16),
                        _buildStep(
                          context: context,
                          index: 1,
                          title: 'The Problem',
                          subtitle: 'Why does this need to exist?',
                          isActive: _currentStep == 1,
                          isCompleted: _currentStep > 1,
                          content: _buildProblemSection(context),
                        ),
                        const SizedBox(height: 16),
                        _buildStep(
                          context: context,
                          index: 2,
                          title: 'Market & Execution',
                          subtitle: 'Who needs this and how will you build it?',
                          isActive: _currentStep == 2,
                          isCompleted: _currentStep > 2,
                          content: _buildExecutionSection(context, state),
                        ),
                        const SizedBox(height: 40),
                        _buildActionButtons(context, state),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  SliverAppBar _buildAppBar(BuildContext context, IdeaFormState state) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.background.withOpacity(0.9),
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textSecondary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        state.isEditing ? 'Refine Idea' : 'New Innovation',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (!state.isEditing)
          TextButton.icon(
            onPressed: () {
              // AI Fill Trigger (Mock)
            },
            icon: const Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.brandCyan,
            ),
            label: const Text(
              'Auto-Fill',
              style: TextStyle(color: AppColors.brandCyan),
            ),
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final customColors = Theme.of(context).extension<StartLinkColors>();
    // Simple 3-step progress
    double progress = (_currentStep + 1) / 3.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Step ${_currentStep + 1} of 3',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}% Ready',
              style: const TextStyle(
                color: AppColors.brandCyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.surfaceGlass,
            valueColor: AlwaysStoppedAnimation(
              customColors?.brandGradient?.colors.last ?? AppColors.brandCyan,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required int index,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
    required Widget content,
  }) {
    final customColors = Theme.of(context).extension<StartLinkColors>();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: StartLinkGlassCard(
        padding: EdgeInsets.zero,
        borderGradient: isActive
            ? (customColors?.brandGradient ?? AppColors.startLinkGradient)
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _currentStep = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _buildStepIcon(isActive, isCompleted),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: isActive
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                          ),
                          if (isActive)
                            Text(
                              subtitle,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isCompleted && !isActive)
                      const Icon(
                        Icons.check,
                        color: AppColors.emerald,
                        size: 20,
                      ),
                    if (!isActive && !isCompleted)
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: content,
              ),
              crossFadeState: isActive
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIcon(bool isActive, bool isCompleted) {
    if (isCompleted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.emerald.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: AppColors.emerald, size: 16),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? AppColors.brandPurple : AppColors.surfaceGlass,
        shape: BoxShape.circle,
        border: isActive
            ? null
            : Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Center(
        child: Text(
          isCompleted ? '✓' : '●', // Simple dot for pending
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // --- Sections ---

  Widget _buildBasicsSection(BuildContext context) {
    return Column(
      children: [
        // Pitch Health Meter
        PitchHealthMeter(
          titleController: _titleController,
          descController: _descController,
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithController(
          label: 'Idea Title',
          hint: 'e.g. "EcoDrone: Solar Surveillance"',
          icon: Icons.lightbulb_outline,
          controller: _titleController,
          validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        _buildTextFieldWithController(
          label: 'One-Liner (Elevator Pitch)',
          hint: 'Describe it in 140 characters...',
          icon: Icons.short_text,
          maxLines: 2,
          controller: _descController,
          validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 24),
        StartLinkButton(
          label: 'Next: Define the Problem',
          onPressed: _nextStep,
          fullWidth: true,
          variant: StartLinkButtonVariant.secondary,
        ),
      ],
    );
  }

  Widget _buildTextFieldWithController({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _inputDecoration(label, icon, hint: hint),
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildProblemSection(BuildContext context) {
    return Column(
      children: [
        _buildTextField(
          label: 'Problem Statement',
          hint: 'What pain are you solving?',
          icon: Icons.warning_amber_rounded,
          maxLines: 4,
          onChanged: (val) =>
              context.read<IdeaFormBloc>().add(ProblemStatementChanged(val)),
          validator: (val) => val?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        // Placeholder for new fields requested in prompt
        _buildTextField(
          label: 'Why existing solutions fail? (Optional)',
          hint: 'Competitors are too expensive / slow...',
          icon: Icons.compare_arrows,
          maxLines: 2,
          onChanged: (val) {}, // Placeholder for future implementation
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => _currentStep = 0),
              child: const Text(
                'Back',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: StartLinkButton(
                label: 'Next: Market Strategy',
                onPressed: _nextStep,
                variant: StartLinkButtonVariant.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutionSection(BuildContext context, IdeaFormState state) {
    return Column(
      children: [
        _buildTextField(
          label: 'Target Market',
          hint: 'e.g. Remote Workers, Pet Owners',
          icon: Icons.people_outline,
          onChanged: (val) =>
              context.read<IdeaFormBloc>().add(TargetMarketChanged(val)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: state.currentStage,
          dropdownColor: AppColors.surfaceGlass,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration('Current Stage', Icons.timeline),
          items: [
            'Idea',
            'Prototype',
            'MVP',
            'Scaling',
          ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (val) {
            if (val != null) {
              context.read<IdeaFormBloc>().add(CurrentStageChanged(val));
            }
          },
        ),
        const SizedBox(height: 16),
        _buildSkillsInput(context, state),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
            'Publicly Visible',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: const Text(
            'Allow investors to find this.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          activeThumbColor: AppColors.brandPurple,
          contentPadding: EdgeInsets.zero,
          value: state.isPublic,
          onChanged: (val) =>
              context.read<IdeaFormBloc>().add(VisibilityChanged(val)),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, IdeaFormState state) {
    return Column(
      children: [
        StartLinkButton(
          label: state.isEditing ? 'Update Idea' : 'Launch Idea',
          icon: Icons.rocket_launch,
          fullWidth: true,
          isLoading: state.status == IdeaFormStatus.loading,
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              context.read<IdeaFormBloc>().add(PublishIdea());
            }
          },
        ),
        const SizedBox(height: 12),
        StartLinkButton(
          label: 'Save as Draft',
          variant: StartLinkButtonVariant.ghost,
          fullWidth: true,
          onPressed: () {
            context.read<IdeaFormBloc>().add(SaveDraft());
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: _inputDecoration(label, icon, hint: hint),
      maxLines: maxLines,
      onChanged: onChanged,
      validator: validator,
    );
  }

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: AppColors.textSecondary.withOpacity(0.5),
        size: 18,
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.3)),
      filled: true,
      fillColor: Colors.black.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandPurple),
      ),
    );
  }

  Widget _buildSkillsInput(BuildContext context, IdeaFormState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _skillController,
                decoration: _inputDecoration(
                  'Required Skills',
                  Icons.code,
                  hint: 'e.g. Python',
                ),
                style: const TextStyle(color: Colors.white),
                onFieldSubmitted: (val) => _addSkill(context, state, val),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _addSkill(context, state, _skillController.text),
              icon: const Icon(Icons.add, color: AppColors.brandCyan),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: state.skills
              .map(
                (skill) => Chip(
                  backgroundColor: AppColors.brandPurple.withOpacity(0.1),
                  side: BorderSide(
                    color: AppColors.brandPurple.withOpacity(0.3),
                  ),
                  label: Text(
                    skill,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  deleteIcon: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  onDeleted: () {
                    final newSkills = List<String>.from(state.skills)
                      ..remove(skill);
                    context.read<IdeaFormBloc>().add(SkillsChanged(newSkills));
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _addSkill(BuildContext context, IdeaFormState state, String val) {
    if (val.isNotEmpty) {
      final newSkills = List<String>.from(state.skills)..add(val);
      context.read<IdeaFormBloc>().add(SkillsChanged(newSkills));
      _skillController.clear();
    }
  }
}
