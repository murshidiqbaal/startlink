import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_dashboard_bloc.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_verification_bloc.dart';
import 'package:startlink/features/investor/presentation/bloc/investor_chat_bloc.dart';
import 'package:startlink/features/investor/presentation/pages/investor_idea_detail_screen.dart';
import 'package:startlink/features/investor/presentation/pages/investor_chat_list_screen.dart';
import 'package:startlink/features/investor/presentation/widgets/investor_idea_card.dart';
import 'package:startlink/features/idea/domain/entities/idea.dart';

class InvestorDashboardScreen extends StatefulWidget {
  const InvestorDashboardScreen({super.key});

  @override
  State<InvestorDashboardScreen> createState() => _InvestorDashboardScreenState();
}

class _InvestorDashboardScreenState extends State<InvestorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  void _loadData() {
    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId != null) {
      context.read<InvestorDashboardBloc>().add(LoadInvestorDashboard());
      context.read<InvestorVerificationBloc>().add(CheckInvestorVerification(userId));
      context.read<InvestorChatBloc>().add(LoadInvestorChats(userId));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Investor Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.brandPurple,
          labelColor: AppColors.brandPurple,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Discover'),
            Tab(text: 'Recommended'),
            Tab(text: 'Saved'),
            Tab(text: 'Conversations'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildRecommendedTab(),
          _buildSavedTab(),
          const InvestorChatListScreen(),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return BlocBuilder<InvestorDashboardBloc, InvestorDashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }
        if (state is DashboardLoaded) {
          return _buildIdeaGrid(state.discoverIdeas);
        }
        return _buildErrorState('Failed to load ideas');
      },
    );
  }

  Widget _buildRecommendedTab() {
    return BlocBuilder<InvestorDashboardBloc, InvestorDashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
        }
        if (state is DashboardLoaded) {
          return _buildIdeaGrid(state.recommendedIdeas);
        }
        return _buildErrorState('No recommendations yet');
      },
    );
  }

  Widget _buildSavedTab() {
    return const Center(
      child: Text('Coming soon: Track your favorite deals', style: TextStyle(color: AppColors.textSecondary)),
    );
  }

  Widget _buildIdeaGrid(List<Idea> ideas) {
    if (ideas.isEmpty) {
      return const Center(child: Text('No ideas found', style: TextStyle(color: AppColors.textSecondary)));
    }
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ideas.length,
        itemBuilder: (context, index) {
          final idea = ideas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InvestorIdeaCard(
              title: idea.title,
              aiSummary: idea.aiSummary,
              stage: idea.currentStage,
              targetMarket: idea.targetMarket,
              imageUrl: idea.coverImageUrl,
              isVerified: idea.isVerified,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => InvestorIdeaDetailScreen(ideaId: idea.id)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.rose),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          TextButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }
}
