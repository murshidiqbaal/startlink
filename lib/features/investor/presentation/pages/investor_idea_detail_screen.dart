import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';
import 'package:startlink/features/idea/domain/repositories/idea_repository.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_chat_bloc.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_verification_bloc.dart';
import 'package:startlink/features/investor/presentation/pages/investor_chat_screen.dart';

class InvestorIdeaDetailScreen extends StatefulWidget {
  final String ideaId;

  const InvestorIdeaDetailScreen({super.key, required this.ideaId});

  @override
  State<InvestorIdeaDetailScreen> createState() => _InvestorIdeaDetailScreenState();
}

class _InvestorIdeaDetailScreenState extends State<InvestorIdeaDetailScreen> {
  Idea? _idea;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIdea();
  }

  Future<void> _loadIdea() async {
    try {
      final repository = context.read<IdeaRepository>();
      final idea = await repository.fetchIdeaById(widget.ideaId);
      if (mounted) {
        setState(() {
          _idea = idea;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.brandPurple)));
    }

    if (_idea == null) {
      return const Scaffold(body: Center(child: Text('Idea not found')));
    }

    return BlocListener<InvestorChatBloc, InvestorChatState>(
      listener: (context, state) {
        if (state is ChatConnectionSuccess) {
          // Navigator.push already preserves global context from App level MultiBlocProvider
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvestorChatScreen(chat: state.chat),
            ),
          );
        }
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.rose),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMainInfo(),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Value Proposition'),
                    Text(_idea!.description, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, height: 1.6)),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Key Features'),
                    _buildChipList(_idea!.tags),
                    const SizedBox(height: 32),
                    _buildEngagementCard(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_idea!.coverImageUrl != null)
              Image.network(_idea!.coverImageUrl!, fit: BoxFit.cover)
            else
              Container(color: AppColors.brandPurple.withValues(alpha: 0.2)),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.background.withValues(alpha: 0.8)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.brandPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_idea!.currentStage.toUpperCase(), 
                style: const TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            if (_idea!.isVerified)
              const Row(
                children: [
                   Icon(Icons.verified, color: AppColors.emerald, size: 16),
                   SizedBox(width: 4),
                   Text('VERIFIED IDEA', style: TextStyle(color: AppColors.emerald, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(_idea!.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 8),
        Text('Founded by ${_idea!.ownerName ?? "Unknown"}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title.toUpperCase(), 
        style: const TextStyle(color: AppColors.brandPurple, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildChipList(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((tag) => Chip(
        label: Text(tag, style: const TextStyle(fontSize: 12)),
        backgroundColor: AppColors.surfaceGlass,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      )).toList(),
    );
  }

  Widget _buildEngagementCard(BuildContext context) {
    return BlocBuilder<InvestorVerificationBloc, InvestorVerificationState>(
      builder: (context, vState) {
        // Safe access to global verification state
        final isVerified = vState is VerificationStatusLoaded && vState.isApproved;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceGlass,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              if (!isVerified)
                _buildVerificationWarning(),
              const SizedBox(height: 16),
              _buildActionButton(
                label: 'Connect with Founder',
                icon: Icons.handshake_outlined,
                onPressed: !isVerified ? null : () => _handleConnect(context),
                primary: true,
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'Request Pitch Deck',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: !isVerified ? null : () => _handleRequestPitch(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 18),
          SizedBox(width: 12),
          Expanded(
            child: Text('Only verified investors can initiate direct contact.', 
              style: TextStyle(color: AppColors.amber, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String label, required IconData icon, VoidCallback? onPressed, bool primary = false}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? AppColors.brandPurple : Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: primary ? BorderSide.none : BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          elevation: 0,
        ),
      ),
    );
  }

  void _handleConnect(BuildContext context) {
    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId == null || _idea == null) return;

    context.read<InvestorChatBloc>().add(ConnectWithInnovator(
      ideaId: _idea!.id,
      investorId: userId,
      innovatorId: _idea!.ownerId,
    ));
  }

  void _handleRequestPitch(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pitch deck request sent to innovator.')),
    );
  }
}
