// lib/features/profile/presentation/edit_investor_profile.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/profile/data/models/investor_profile_model.dart';
import 'package:startlink/features/profile/domain/entities/investor_profile.dart';
import 'package:startlink/features/profile/domain/repositories/profile_repository.dart';
import 'package:startlink/features/profile/presentation/bloc/role_profile_bloc.dart';

class EditInvestorProfileScreen extends StatelessWidget {
  /// The profile's profiles.id — required to fetch/save role row
  final String profileId;
  const EditInvestorProfileScreen({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) =>
          InvestorProfileBloc(repository: ctx.read<ProfileRepository>())
            ..add(LoadInvestorProfile(profileId)),
      child: _EditInvestorBody(profileId: profileId),
    );
  }
}

class _EditInvestorBody extends StatefulWidget {
  final String profileId;
  const _EditInvestorBody({required this.profileId});
  @override
  State<_EditInvestorBody> createState() => _EditInvestorBodyState();
}

class _EditInvestorBodyState extends State<_EditInvestorBody> {
  final _formKey = GlobalKey<FormState>();

  final _orgCtrl = TextEditingController();
  final _focusCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  final _linkedinCtrl = TextEditingController();
  String? _stage;

  bool _populated = false;

  @override
  void dispose() {
    for (final c in [_orgCtrl, _focusCtrl, _minCtrl, _maxCtrl, _linkedinCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _populate(InvestorProfileModel m) {
    if (_populated) return;
    _populated = true;
    setState(() {
      _orgCtrl.text = m.organizationName ?? '';
      _focusCtrl.text = m.investmentFocus ?? '';
      _minCtrl.text = m.ticketSizeMin?.toStringAsFixed(0) ?? '';
      _maxCtrl.text = m.ticketSizeMax?.toStringAsFixed(0) ?? '';
      _linkedinCtrl.text = m.linkedinUrl ?? '';
      _stage = m.preferredStage;
    });
  }

  int _calcCompletion() {
    int s = 0;
    if (_orgCtrl.text.trim().isNotEmpty) s += 25;
    if (_focusCtrl.text.trim().isNotEmpty) s += 25;
    if (_stage != null) s += 20;
    if (_minCtrl.text.isNotEmpty) s += 15;
    if (_linkedinCtrl.text.trim().isNotEmpty) s += 15;
    return s;
  }

  void _save(InvestorProfile existing) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final updated = InvestorProfileModel(
      profileId: existing.profileId,
      organizationName: _noe(_orgCtrl.text),
      investmentFocus: _noe(_focusCtrl.text),
      ticketSizeMin: double.tryParse(_minCtrl.text),
      ticketSizeMax: double.tryParse(_maxCtrl.text),
      preferredStage: _stage,
      linkedinUrl: _noe(_linkedinCtrl.text),
      profileCompletion: _calcCompletion(),
      isVerified: existing.isVerified,
    );
    context.read<InvestorProfileBloc>().add(
      SaveInvestorProfile(updated as InvestorProfile),
    );
  }

  String? _noe(String v) => v.trim().isEmpty ? null : v.trim();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InvestorProfileBloc, InvestorProfileState>(
      listener: (ctx, state) {
        if (state is InvestorProfileLoaded && !_populated) {
          _populate(state.profile! as InvestorProfileModel);
        }
        if (state is InvestorProfileSaved) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Investor profile saved ✓'),
              backgroundColor: AppColors.emerald,
            ),
          );
          Navigator.pop(ctx, true);
        }
        if (state is InvestorProfileError) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.rose,
            ),
          );
        }
      },
      builder: (ctx, state) {
        final isLoading = state is InvestorProfileLoading;
        final isSaving = state is InvestorProfileSaving;
        final existing = state is InvestorProfileLoaded
            ? state.profile
            : InvestorProfileModel(profileId: widget.profileId);

        if (isLoading) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.brandPurple),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              'Edit Investor Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => Navigator.pop(ctx),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brandPurple,
                        ),
                      )
                    : TextButton(
                        onPressed: () => _save(existing),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.brandPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                // Completion banner
                _CompletionBar(pct: _calcCompletion()),
                const SizedBox(height: 24),

                _sectionLabel('Organization'),
                const SizedBox(height: 12),
                _tf(
                  'Organization Name *',
                  Icons.business,
                  _orgCtrl,
                  validator: _req,
                ),
                const SizedBox(height: 12),
                _tf(
                  'LinkedIn URL',
                  Icons.link,
                  _linkedinCtrl,
                  hint: 'https://linkedin.com/in/…',
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 24),
                _sectionLabel('Investment Focus'),
                const SizedBox(height: 12),
                _tf(
                  'Investment Focus *',
                  Icons.track_changes,
                  _focusCtrl,
                  hint: 'SaaS, Fintech, Health',
                  validator: _req,
                ),
                const SizedBox(height: 12),
                _ddNullable(
                  'Preferred Stage',
                  Icons.layers,
                  _stage,
                  ['Pre-Seed', 'Seed', 'Series A', 'Series B', 'Growth'],
                  (v) => setState(() => _stage = v),
                ),

                const SizedBox(height: 24),
                _sectionLabel('Ticket Size'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _tf(
                        'Min (\$)',
                        Icons.attach_money,
                        _minCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _tf(
                        'Max (\$)',
                        Icons.attach_money,
                        _maxCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                SizedBox(
                  height: 54,
                  child: isSaving
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brandPurple,
                          ),
                        )
                      : _gradientBtn(
                          'Save Profile',
                          () => _save(existing),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _req(String? v) => v?.trim().isEmpty == true ? 'Required' : null;
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS (investor + mentor edit screens)
// ─────────────────────────────────────────────────────────────────────────────

class _CompletionBar extends StatelessWidget {
  final int pct;
  const _CompletionBar({required this.pct});

  Color get _c {
    if (pct < 40) return AppColors.rose;
    if (pct < 70) return AppColors.amber;
    return AppColors.emerald;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.surfaceGlass,
        border: Border.all(color: _c.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Profile Strength',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '$pct%',
                style: TextStyle(
                  color: _c,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.07),
              valueColor: AlwaysStoppedAnimation<Color>(_c),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sectionLabel(String text) => Text(
  text.toUpperCase(),
  style: const TextStyle(
    color: AppColors.brandPurple,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  ),
);

InputDecoration _dec2(String label, IconData icon, {String? hint}) =>
    InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.25),
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

Widget _tf(
  String label,
  IconData icon,
  TextEditingController ctrl, {
  String? hint,
  int maxLines = 1,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  String? Function(String?)? validator,
}) => TextFormField(
  controller: ctrl,
  maxLines: maxLines,
  keyboardType: keyboardType,
  inputFormatters: inputFormatters,
  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
  decoration: _dec2(label, icon, hint: hint),
  validator: validator,
);

Widget _ddNullable(
  String label,
  IconData icon,
  String? value,
  List<String> items,
  ValueChanged<String?> onChanged,
) => DropdownButtonFormField<String>(
  value: value,
  dropdownColor: const Color(0xFF1A1A22),
  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
  decoration: _dec2(label, icon),
  items: [
    const DropdownMenuItem<String>(
      value: null,
      child: Text('Select…', style: TextStyle(color: AppColors.textSecondary)),
    ),
    ...items.map((e) => DropdownMenuItem(value: e, child: Text(e))),
  ],
  onChanged: onChanged,
);

Widget _gradientBtn(String label, VoidCallback? onPressed) => Material(
  color: Colors.transparent,
  child: Ink(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: const LinearGradient(
        colors: [AppColors.brandPurple, AppColors.brandCyan],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ),
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    ),
  ),
);
