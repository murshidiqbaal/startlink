import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:startlink/core/presentation/widgets/space_0/aura_overlay.dart';
import 'package:startlink/core/presentation/widgets/startlink_button.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/idea/presentation/bloc/idea_form_bloc.dart';
import 'package:startlink/features/pitch_health/presentation/widgets/pitch_health_meter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

class IdeaPostScreen extends StatelessWidget {
  final Idea? idea;
  const IdeaPostScreen({super.key, this.idea});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          IdeaFormBloc(ideaRepository: ctx.read<IdeaRepository>())
            ..add(InitializeForm(idea)),
      child: _IdeaPostBody(idea: idea),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP METADATA
// ─────────────────────────────────────────────────────────────────────────────

const _kSteps = [
  (icon: Icons.lightbulb_outline, label: 'Basic'),
  (icon: Icons.business_center_outlined, label: 'Details'),
  (icon: Icons.monetization_on_outlined, label: 'Funding'),
  (icon: Icons.perm_media_outlined, label: 'Media'),
  (icon: Icons.tune_outlined, label: 'Publish'),
];

const _kLabels = [
  'Basic Info',
  'Startup Details',
  'Funding & Team',
  'Media & Links',
  'Review & Publish',
];

const _kSubtitles = [
  'Your idea in a nutshell',
  'Industry, model & stage',
  'Investment & team structure',
  'Cover image, deck & demo',
  'Final check before launch',
];

// ─────────────────────────────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────────────────────────────

class _IdeaPostBody extends StatefulWidget {
  final Idea? idea;
  const _IdeaPostBody({this.idea});

  @override
  State<_IdeaPostBody> createState() => _IdeaPostBodyState();
}

class _IdeaPostBodyState extends State<_IdeaPostBody>
    with TickerProviderStateMixin {
  // ── Navigation ─────────────────────────────────────────────────────────
  final _pageCtrl = PageController();
  int _step = 0;
  bool _isSubmitting = false;

  // ── Per-step form keys ─────────────────────────────────────────────────
  final _fk = List.generate(5, (_) => GlobalKey<FormState>());

  // ── Step 1: Basic Info ─────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _problemCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();
  List<String> _tags = [];

  // ── Step 2: Startup Details ────────────────────────────────────────────
  String _industry = 'Technology';
  final _subIndustryCtrl = TextEditingController();
  String _businessModel = 'SaaS';
  final _monetizationCtrl = TextEditingController();
  String _currentStage = 'Idea';
  final _locationCtrl = TextEditingController();

  // ── Step 3: Funding & Team ─────────────────────────────────────────────
  final _fundingCtrl = TextEditingController();
  final _equityCtrl = TextEditingController();
  bool _wantsInvestor = false;
  bool _wantsCofounder = false;
  bool _wantsMentor = false;
  int _teamSize = 1;

  // ── Step 4: Media & Links ──────────────────────────────────────────────
  File? _coverImage;
  final _pitchDeckCtrl = TextEditingController();
  final _demoVideoCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();

  // ── Step 5: Visibility ─────────────────────────────────────────────────
  String _visibility = 'public';

  @override
  void initState() {
    super.initState();
    final idea = widget.idea;
    if (idea != null) {
      _titleCtrl.text = idea.title;
      _descCtrl.text = idea.description;
      _problemCtrl.text = idea.problemStatement;
      _targetCtrl.text = idea.targetMarket;
      _tags = List.from(idea.tags);
      _currentStage = idea.currentStage;
      _visibility = idea.isPublic ? 'public' : 'private';
      _industry = idea.industry ?? 'Technology';
      _subIndustryCtrl.text = idea.subIndustry ?? '';
      _businessModel = idea.businessModel ?? 'SaaS';
      _monetizationCtrl.text = idea.monetizationStrategy ?? '';
      _locationCtrl.text = idea.location ?? '';
      _fundingCtrl.text = idea.fundingNeeded?.toString() ?? '';
      _equityCtrl.text = idea.equityOffered?.toString() ?? '';
      _teamSize = idea.teamSize;
      _wantsInvestor = idea.lookingForInvestor;
      _wantsCofounder = idea.lookingForCofounder;
      _wantsMentor = idea.lookingForMentor;
      _pitchDeckCtrl.text = idea.pitchDeckUrl ?? '';
      _demoVideoCtrl.text = idea.demoVideoUrl ?? '';
      _websiteCtrl.text = idea.websiteUrl ?? '';

      // Initialize BLoC state with existing idea
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<IdeaFormBloc>().add(InitializeForm(idea));
      });
    }

    final bloc = context.read<IdeaFormBloc>();
    _titleCtrl.addListener(() => bloc.add(TitleChanged(_titleCtrl.text)));
    _descCtrl.addListener(() => bloc.add(DescriptionChanged(_descCtrl.text)));
    _problemCtrl.addListener(
      () => bloc.add(ProblemStatementChanged(_problemCtrl.text)),
    );
    _targetCtrl.addListener(
      () => bloc.add(TargetMarketChanged(_targetCtrl.text)),
    );
    _subIndustryCtrl.addListener(
      () => bloc.add(SubIndustryChanged(_subIndustryCtrl.text)),
    );
    _monetizationCtrl.addListener(
      () => bloc.add(MonetizationStrategyChanged(_monetizationCtrl.text)),
    );
    _locationCtrl.addListener(
      () => bloc.add(LocationChanged(_locationCtrl.text)),
    );
    _fundingCtrl.addListener(() {
      final val = double.tryParse(_fundingCtrl.text) ?? 0.0;
      bloc.add(FundingNeededChanged(val));
    });
    _equityCtrl.addListener(() {
      final val = double.tryParse(_equityCtrl.text) ?? 0.0;
      bloc.add(EquityOfferedChanged(val));
    });
    _pitchDeckCtrl.addListener(
      () => bloc.add(PitchDeckUrlChanged(_pitchDeckCtrl.text)),
    );
    _demoVideoCtrl.addListener(
      () => bloc.add(DemoVideoUrlChanged(_demoVideoCtrl.text)),
    );
    _websiteCtrl.addListener(
      () => bloc.add(WebsiteUrlChanged(_websiteCtrl.text)),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    for (final c in [
      _titleCtrl,
      _descCtrl,
      _problemCtrl,
      _targetCtrl,
      _tagInputCtrl,
      _subIndustryCtrl,
      _monetizationCtrl,
      _locationCtrl,
      _fundingCtrl,
      _equityCtrl,
      _pitchDeckCtrl,
      _demoVideoCtrl,
      _websiteCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  void _goTo(int step) {
    _pageCtrl.animateToPage(
      step,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void _next() {
    if (!(_fk[_step].currentState?.validate() ?? true)) return;
    if (_step < 4) _goTo(_step + 1);
  }

  void _back() {
    if (_step > 0) _goTo(_step - 1);
  }

  void _addTag() {
    for (final raw in _tagInputCtrl.text.split(',')) {
      final t = raw.trim();
      if (t.isNotEmpty && !_tags.contains(t) && _tags.length < 10) {
        _tags.add(t);
      }
    }
    _tagInputCtrl.clear();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (p != null) {
      final file = File(p.path);
      setState(() => _coverImage = file);
      context.read<IdeaFormBloc>().add(CoverImageFileChanged(file));
    }
  }

  void _submitNewIdea() {
    context.read<IdeaFormBloc>().add(PublishIdea());
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx) {
    final bloc = ctx.read<IdeaFormBloc>();
    showDialog<bool>(
      context: ctx,
      builder: (d) => AlertDialog(
        backgroundColor: AppColors.surfaceGlass,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Idea?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(d, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.rose),
            ),
          ),
        ],
      ),
    ).then((ok) {
      if (ok == true) bloc.add(DeleteIdea());
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IdeaFormBloc, IdeaFormState>(
      listener: (ctx, state) {
        if (state.status == IdeaFormStatus.failure) {
          _showError(state.errorMessage ?? 'An error occurred');
        } else if (state.status == IdeaFormStatus.success) {
          final msg = state.isDeleted
              ? 'Idea Deleted'
              : state.isDraft
              ? 'Saved to Lab ✦'
              : 'Idea Updated';
          AuraOverlay.show(ctx, msg, isError: state.isDeleted);
          Navigator.pop(ctx, true);
        }
      },
      builder: (ctx, blocState) {
        final isBlocLoading = blocState.status == IdeaFormStatus.loading;
        final isLoading = _isSubmitting || isBlocLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leadingWidth: 48,
            leading: IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () => Navigator.pop(ctx),
            ),
            title: _StepIndicator(step: _step),
            centerTitle: true,
            actions: [
              if (!blocState.isEditing)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandCyan,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: null,
                    icon: const Icon(Icons.auto_awesome, size: 14),
                    label: const Text('Auto-Fill'),
                  ),
                ),
            ],
          ),
          body: BlocListener<IdeaFormBloc, IdeaFormState>(
            listener: (context, state) {
              if (state.status == IdeaFormStatus.success) {
                final msg = state.isDraft
                    ? 'Draft Saved! 💾'
                    : 'Idea Launched! 🚀';
                AuraOverlay.show(context, msg);
                Navigator.pop(context, true);
              } else if (state.status == IdeaFormStatus.failure) {
                _showError(state.errorMessage ?? 'Submission failed');
              }
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    _StepLabelRow(step: _step),
                    const SizedBox(height: 4),
                    Expanded(
                      child: PageView(
                        controller: _pageCtrl,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) => setState(() => _step = i),
                        children: [
                          // ── Step 1 ──────────────────────────────────────
                          _StepPage(
                            formKey: _fk[0],
                            child: _Step1Basic(
                              titleCtrl: _titleCtrl,
                              descCtrl: _descCtrl,
                              problemCtrl: _problemCtrl,
                              targetCtrl: _targetCtrl,
                              tagInputCtrl: _tagInputCtrl,
                              tags: _tags,
                              onAddTag: _addTag,
                              onRemoveTag: (t) =>
                                  setState(() => _tags.remove(t)),
                              onProblemChanged: (v) => ctx
                                  .read<IdeaFormBloc>()
                                  .add(ProblemStatementChanged(v)),
                              onTargetChanged: (v) => ctx
                                  .read<IdeaFormBloc>()
                                  .add(TargetMarketChanged(v)),
                            ),
                          ),
                          // ── Step 2 ──────────────────────────────────────
                          _StepPage(
                            formKey: _fk[1],
                            child: _Step2Details(
                              industry: _industry,
                              onIndustryChanged: (v) {
                                setState(() => _industry = v);
                                ctx.read<IdeaFormBloc>().add(
                                  IndustryChanged(v),
                                );
                              },
                              subIndustryCtrl: _subIndustryCtrl,
                              businessModel: _businessModel,
                              onBusinessModelChanged: (v) {
                                setState(() => _businessModel = v);
                                ctx.read<IdeaFormBloc>().add(
                                  BusinessModelChanged(v),
                                );
                              },
                              monetizationCtrl: _monetizationCtrl,
                              currentStage: _currentStage,
                              onStageChanged: (v) {
                                setState(() => _currentStage = v);
                                ctx.read<IdeaFormBloc>().add(
                                  CurrentStageChanged(v),
                                );
                              },
                              locationCtrl: _locationCtrl,
                            ),
                          ),
                          // ── Step 3 ──────────────────────────────────────
                          _StepPage(
                            formKey: _fk[2],
                            child: _Step3Funding(
                              fundingCtrl: _fundingCtrl,
                              equityCtrl: _equityCtrl,
                              teamSize: _teamSize,
                              onTeamSizeChanged: (v) {
                                setState(() => _teamSize = v);
                                ctx.read<IdeaFormBloc>().add(
                                  TeamSizeChanged(v),
                                );
                              },
                              wantsInvestor: _wantsInvestor,
                              onInvestorChanged: (v) {
                                setState(() => _wantsInvestor = v);
                                ctx.read<IdeaFormBloc>().add(
                                  LookingForInvestorChanged(v),
                                );
                              },
                              wantsCofounder: _wantsCofounder,
                              onCofounderChanged: (v) {
                                setState(() => _wantsCofounder = v);
                                ctx.read<IdeaFormBloc>().add(
                                  LookingForCofounderChanged(v),
                                );
                              },
                              wantsMentor: _wantsMentor,
                              onMentorChanged: (v) {
                                setState(() => _wantsMentor = v);
                                ctx.read<IdeaFormBloc>().add(
                                  LookingForMentorChanged(v),
                                );
                              },
                            ),
                          ),
                          // ── Step 4 ──────────────────────────────────────
                          _StepPage(
                            formKey: _fk[3],
                            child: _Step4Media(
                              coverImage: _coverImage,
                              onPickImage: _pickImage,
                              pitchDeckCtrl: _pitchDeckCtrl,
                              demoVideoCtrl: _demoVideoCtrl,
                              websiteCtrl: _websiteCtrl,
                            ),
                          ),
                          // ── Step 5 ──────────────────────────────────────
                          _StepPage(
                            formKey: _fk[4],
                            child: _Step5Publish(
                              visibility: _visibility,
                              onVisibilityChanged: (v) {
                                setState(() => _visibility = v);
                                ctx.read<IdeaFormBloc>().add(
                                  VisibilityChanged(v == 'public'),
                                );
                              },
                              coverImage: _coverImage,
                              title: _titleCtrl.text,
                              description: _descCtrl.text,
                              currentStage: _currentStage,
                              funding: _fundingCtrl.text,
                              equity: _equityCtrl.text,
                              tags: _tags,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ── Sticky bottom bar ───────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomBar(
                    step: _step,
                    isEditing: blocState.isEditing,
                    isLoading: isLoading,
                    onBack: _back,
                    onNext: _next,
                    onSaveDraft: () =>
                        ctx.read<IdeaFormBloc>().add(SaveDraft()),
                    onDelete: () => _confirmDelete(ctx),
                    onSubmit: () {
                      if (blocState.isEditing) {
                        if (_fk[_step].currentState?.validate() ?? false) {
                          ctx.read<IdeaFormBloc>().add(PublishIdea());
                        }
                      } else {
                        _submitNewIdea();
                      }
                    },
                  ),
                ),

                // ── Loading overlay ─────────────────────────────────────
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.65),
                    child: const Center(child: _LoadingCard()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP INDICATOR
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    const total = 5;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          final done = (i ~/ 2) < step;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: done
                    ? const LinearGradient(
                        colors: [AppColors.brandPurple, AppColors.brandCyan],
                      )
                    : null,
                color: done ? null : Colors.white.withValues(alpha: 0.1),
              ),
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < step;
        final active = idx == step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? const LinearGradient(
                    colors: [AppColors.brandPurple, AppColors.brandCyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: done
                ? AppColors.emerald.withValues(alpha: 0.2)
                : active
                ? null
                : Colors.white.withValues(alpha: 0.06),
            border: Border.all(
              color: done
                  ? AppColors.emerald.withValues(alpha: 0.7)
                  : active
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Icon(
            done ? Icons.check : _kSteps[idx].icon,
            size: 14,
            color: done
                ? AppColors.emerald
                : active
                ? Colors.white
                : AppColors.textSecondary,
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP LABEL ROW
// ─────────────────────────────────────────────────────────────────────────────

class _StepLabelRow extends StatelessWidget {
  final int step;
  const _StepLabelRow({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _kLabels[step],
              key: ValueKey(_kLabels[step]),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _kSubtitles[step],
              key: ValueKey(_kSubtitles[step]),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP PAGE WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _StepPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget child;
  const _StepPage({required this.formKey, required this.child});

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────

InputDecoration _dec(String label, IconData icon, {String? hint}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.28),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.brandPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.rose),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );

DropdownButtonFormField<String> _dropdown(
  String label,
  IconData icon,
  String value,
  List<String> items,
  ValueChanged<String?> onChanged,
) =>   DropdownButtonFormField<String>(
  value: items.contains(value) ? value : (items.contains('Other') ? 'Other' : items.first),
  dropdownColor: const Color(0xFF1A1A22),
  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
  decoration: _dec(label, icon),
  items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  onChanged: onChanged,
);

Widget _sectionDivider(String label) => Padding(
  padding: const EdgeInsets.only(top: 24, bottom: 12),
  child: Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
    ],
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Basic Info
// ─────────────────────────────────────────────────────────────────────────────

class _Step1Basic extends StatelessWidget {
  final TextEditingController titleCtrl,
      descCtrl,
      problemCtrl,
      targetCtrl,
      tagInputCtrl;
  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<String> onRemoveTag;
  final ValueChanged<String> onProblemChanged, onTargetChanged;

  const _Step1Basic({
    required this.titleCtrl,
    required this.descCtrl,
    required this.problemCtrl,
    required this.targetCtrl,
    required this.tagInputCtrl,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    required this.onProblemChanged,
    required this.onTargetChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PitchHealthMeter(titleController: titleCtrl, descController: descCtrl),
        const SizedBox(height: 20),
        TextFormField(
          controller: titleCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Startup Title *',
            Icons.lightbulb_outline,
            hint: 'e.g. EcoDrone: AI Solar Surveillance',
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: descCtrl,
          maxLines: 4,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Elevator Pitch *',
            Icons.short_text,
            hint: 'Describe your startup in a compelling paragraph...',
          ),
          validator: (v) => (v == null || v.trim().length < 20)
              ? 'At least 20 characters required'
              : null,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: problemCtrl,
          maxLines: 2,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Problem Statement',
            Icons.warning_amber_rounded,
            hint: 'What pain point are you solving?',
          ),
          onChanged: onProblemChanged,
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: targetCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Target Market',
            Icons.people_outline,
            hint: 'e.g. Remote workers, Gen-Z consumers',
          ),
          onChanged: onTargetChanged,
        ),
        _sectionDivider('TAGS  ·  MAX 10'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: tagInputCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dec(
                  'Add tags',
                  Icons.label_outline,
                  hint: 'AI, Fintech, SaaS — comma separated',
                ),
                onFieldSubmitted: (_) => onAddTag(),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onAddTag,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [AppColors.brandPurple, AppColors.brandCyan],
                    ),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
        if (tags.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: tags
                .map(
                  (tag) => Chip(
                    backgroundColor: AppColors.brandPurple.withValues(
                      alpha: 0.14,
                    ),
                    side: BorderSide(
                      color: AppColors.brandPurple.withValues(alpha: 0.4),
                    ),
                    label: Text(
                      tag,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                      ),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                    onDeleted: () => onRemoveTag(tag),
                    visualDensity: VisualDensity.compact,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Startup Details
// ─────────────────────────────────────────────────────────────────────────────

class _Step2Details extends StatelessWidget {
  final String industry, businessModel, currentStage;
  final TextEditingController subIndustryCtrl, monetizationCtrl, locationCtrl;
  final ValueChanged<String> onIndustryChanged,
      onBusinessModelChanged,
      onStageChanged;

  const _Step2Details({
    required this.industry,
    required this.onIndustryChanged,
    required this.subIndustryCtrl,
    required this.businessModel,
    required this.onBusinessModelChanged,
    required this.monetizationCtrl,
    required this.currentStage,
    required this.onStageChanged,
    required this.locationCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _dropdown('Industry', Icons.factory_outlined, industry, [
          'Technology',
          'Healthcare',
          'Finance',
          'Education',
          'GreenTech',
          'Logistics',
          'Agriculture',
          'Real Estate',
          'Media & Entertainment',
          'Other',
        ], (v) => onIndustryChanged(v!)),
        const SizedBox(height: 14),
        TextFormField(
          controller: subIndustryCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Sub-industry',
            Icons.category_outlined,
            hint: 'e.g. EdTech, HRTech, AgriTech',
          ),
        ),
        const SizedBox(height: 14),
        _dropdown(
          'Business Model',
          Icons.account_balance_outlined,
          businessModel,
          [
            'SaaS',
            'Marketplace',
            'E-commerce',
            'Subscription',
            'B2B',
            'B2C',
            'B2G (Business-to-Government)',
            'D2C',
            'Freemium',
            'Other',
          ],
          (v) => onBusinessModelChanged(v!),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: monetizationCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Monetization Strategy',
            Icons.attach_money_outlined,
            hint: 'e.g. Monthly subscriptions + commissions',
          ),
        ),
        const SizedBox(height: 14),
        _dropdown('Current Stage', Icons.timeline, currentStage, [
          'Idea',
          'Prototype',
          'MVP',
          'Beta',
          'Launched',
          'Scaling',
        ], (v) => onStageChanged(v!)),
        const SizedBox(height: 14),
        TextFormField(
          controller: locationCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'HQ Location',
            Icons.location_on_outlined,
            hint: 'e.g. San Francisco, CA / Remote',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Funding & Team
// ─────────────────────────────────────────────────────────────────────────────

class _Step3Funding extends StatelessWidget {
  final TextEditingController fundingCtrl, equityCtrl;
  final int teamSize;
  final ValueChanged<int> onTeamSizeChanged;
  final bool wantsInvestor, wantsCofounder, wantsMentor;
  final ValueChanged<bool> onInvestorChanged,
      onCofounderChanged,
      onMentorChanged;

  const _Step3Funding({
    required this.fundingCtrl,
    required this.equityCtrl,
    required this.teamSize,
    required this.onTeamSizeChanged,
    required this.wantsInvestor,
    required this.onInvestorChanged,
    required this.wantsCofounder,
    required this.onCofounderChanged,
    required this.wantsMentor,
    required this.onMentorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: fundingCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dec(
                  'Funding Needed (\$)',
                  Icons.price_check_outlined,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: equityCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: _dec('Equity Offered (%)', Icons.pie_chart_outline),
              ),
            ),
          ],
        ),
        _sectionDivider('TEAM'),
        StartLinkGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.groups_2_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Team Size',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  if (teamSize > 1) onTeamSizeChanged(teamSize - 1);
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '$teamSize',
                  key: ValueKey(teamSize),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.brandCyan,
                ),
                onPressed: () => onTeamSizeChanged(teamSize + 1),
              ),
            ],
          ),
        ),
        _sectionDivider('SEEKING'),
        _SwitchRow(
          icon: Icons.business_outlined,
          label: 'Looking for Investors',
          value: wantsInvestor,
          onChanged: onInvestorChanged,
        ),
        const SizedBox(height: 8),
        _SwitchRow(
          icon: Icons.handshake_outlined,
          label: 'Looking for Co-Founders',
          value: wantsCofounder,
          onChanged: onCofounderChanged,
        ),
        const SizedBox(height: 8),
        _SwitchRow(
          icon: Icons.school_outlined,
          label: 'Looking for Mentors',
          value: wantsMentor,
          onChanged: onMentorChanged,
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StartLinkGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderGradient: value ? AppColors.startLinkGradient : null,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: value ? AppColors.brandPurple : AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: value ? AppColors.textPrimary : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brandPurple,
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Media & Links
// ─────────────────────────────────────────────────────────────────────────────

class _Step4Media extends StatelessWidget {
  final File? coverImage;
  final VoidCallback onPickImage;
  final TextEditingController pitchDeckCtrl, demoVideoCtrl, websiteCtrl;

  const _Step4Media({
    required this.coverImage,
    required this.onPickImage,
    required this.pitchDeckCtrl,
    required this.demoVideoCtrl,
    required this.websiteCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPickImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.surfaceGlass,
              border: Border.all(
                color: coverImage != null
                    ? AppColors.brandPurple.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.08),
                width: coverImage != null ? 1.5 : 1,
              ),
              image: coverImage != null
                  ? DecorationImage(
                      image: FileImage(coverImage!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: coverImage == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brandPurple.withValues(alpha: 0.1),
                          border: Border.all(
                            color: AppColors.brandPurple.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 26,
                          color: AppColors.brandPurple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Add Cover Image',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Recommended 1280 × 720',
                        style: TextStyle(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  )
                : Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black.withValues(alpha: 0.55),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        _sectionDivider('LINKS'),
        TextFormField(
          controller: pitchDeckCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Pitch Deck URL',
            Icons.picture_as_pdf_outlined,
            hint: 'https://docsend.com/...',
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: demoVideoCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Demo Video URL',
            Icons.play_circle_outline,
            hint: 'https://youtube.com/...',
          ),
        ),
        const SizedBox(height: 14),
        TextFormField(
          controller: websiteCtrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _dec(
            'Website / Landing Page',
            Icons.language_outlined,
            hint: 'https://yourstartup.com',
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5 — Review & Publish
// ─────────────────────────────────────────────────────────────────────────────

class _Step5Publish extends StatelessWidget {
  final String visibility, title, description, currentStage, funding, equity;
  final List<String> tags;
  final File? coverImage;
  final ValueChanged<String> onVisibilityChanged;

  const _Step5Publish({
    required this.visibility,
    required this.onVisibilityChanged,
    required this.coverImage,
    required this.title,
    required this.description,
    required this.currentStage,
    required this.funding,
    required this.equity,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StartLinkGlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (coverImage != null)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14),
                  ),
                  child: Image.file(
                    coverImage!,
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title.isEmpty ? '(No title yet)' : title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description.isEmpty
                          ? '(No description yet)'
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _PreviewStat(label: 'Stage', value: currentStage),
                        _PreviewStat(
                          label: 'Funding',
                          value: funding.isEmpty ? '—' : '\$$funding',
                        ),
                        _PreviewStat(
                          label: 'Equity',
                          value: equity.isEmpty ? '—' : '$equity%',
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: tags
                            .take(6)
                            .map(
                              (t) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: AppColors.brandPurple.withValues(
                                    alpha: 0.15,
                                  ),
                                ),
                                child: Text(
                                  '#$t',
                                  style: const TextStyle(
                                    color: AppColors.brandCyan,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        _sectionDivider('VISIBILITY'),
        _dropdown(
          'Who can see this?',
          Icons.visibility_outlined,
          visibility,
          ['public', 'private'],
          (v) => onVisibilityChanged(v!),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.emerald.withValues(alpha: 0.07),
            border: Border.all(
              color: AppColors.emerald.withValues(alpha: 0.25),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: AppColors.emerald,
                size: 18,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Status will be set to "published" · immediately discoverable by investors and co-founders.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewStat extends StatelessWidget {
  final String label, value;
  const _PreviewStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STICKY BOTTOM BAR
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int step;
  final bool isEditing, isLoading;
  final VoidCallback onBack, onNext, onSaveDraft, onDelete, onSubmit;

  const _BottomBar({
    required this.step,
    required this.isEditing,
    required this.isLoading,
    required this.onBack,
    required this.onNext,
    required this.onSaveDraft,
    required this.onDelete,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = step == 4;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (step > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 48,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      onPressed: isLoading ? null : onBack,
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: isLast
                      ? _GradientButton(
                          label: isEditing ? 'Update Idea' : 'Launch Idea 🚀',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : onSubmit,
                        )
                      : StartLinkButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward,
                          fullWidth: true,
                          variant: StartLinkButtonVariant.secondary,
                          onPressed: isLoading ? null : onNext,
                        ),
                ),
              ),
            ],
          ),
          if (isLast && !isEditing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: StartLinkButton(
                label: 'Save as Draft',
                variant: StartLinkButtonVariant.ghost,
                fullWidth: true,
                onPressed: isLoading ? null : onSaveDraft,
              ),
            ),
          ],
          if (isLast && isEditing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: StartLinkButton(
                label: 'Delete Idea',
                variant: StartLinkButtonVariant.ghost,
                fullWidth: true,
                textColor: AppColors.rose,
                icon: Icons.delete_outline,
                onPressed: isLoading ? null : onDelete,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GRADIENT LAUNCH BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _GradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: onPressed == null
              ? const LinearGradient(
                  colors: [Color(0xFF4A3080), Color(0xFF2A6080)],
                )
              : const LinearGradient(
                  colors: [AppColors.brandPurple, AppColors.brandCyan],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOADING CARD
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      margin: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.surfaceGlass,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: AppColors.brandPurple,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Launching your idea...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Uploading to StartLink 🚀',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
