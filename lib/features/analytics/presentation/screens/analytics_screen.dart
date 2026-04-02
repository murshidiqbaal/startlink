import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/core/presentation/widgets/startlink_glass_card.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import '../bloc/analytics_bloc.dart';
import '../../domain/models/analytics_data.dart';
import '../../domain/models/idea_performance.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final innovatorId = context.read<AuthRepository>().currentUser?.id;

    if (innovatorId == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to see analytics")),
      );
    }

    return BlocProvider.value(
      value: context.read<AnalyticsBloc>()..add(LoadAnalytics(innovatorId)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            "Analytics Dashboard",
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.background,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.brandCyan),
              onPressed: () {
                context.read<AnalyticsBloc>().add(RefreshAnalytics(innovatorId));
              },
            ),
          ],
        ),
        body: BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) {
            if (state is AnalyticsLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
            }

            if (state is AnalyticsError) {
              return Center(child: Text("Error: ${state.message}", style: const TextStyle(color: Colors.red)));
            }

            if (state is AnalyticsLoaded) {
              if (state.data.totalIdeas == 0) {
                return _buildEmptyState();
              }
              return _AnalyticsView(data: state.data);
            }

            return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 24),
          const Text(
            "No data to analyze yet",
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Post your first idea to start tracking performance!",
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsView extends StatelessWidget {
  final AnalyticsData data;
  const _AnalyticsView({required this.data});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
         final innovatorId = context.read<AuthRepository>().currentUser?.id;
         if (innovatorId != null) {
           context.read<AnalyticsBloc>().add(RefreshAnalytics(innovatorId));
         }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricGrid(),
            const SizedBox(height: 32),
            _buildEngagementChart(),
            const SizedBox(height: 32),
            _buildTopIdeasSection(),
            const SizedBox(height: 32),
            _buildSmartInsightsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(label: "Total Ideas", value: data.totalIdeas.toString(), icon: Icons.lightbulb, color: AppColors.brandCyan),
        _MetricCard(label: "Requests", value: data.totalRequests.toString(), icon: Icons.work_history, color: AppColors.amber),
        _MetricCard(label: "Collaborators", value: data.totalCollaborators.toString(), icon: Icons.group, color: AppColors.brandPurple),
        _MetricCard(label: "Investor Interest", value: data.investorInterest.toString(), icon: Icons.monetization_on, color: Colors.greenAccent),
        _MetricCard(label: "Engagement", value: data.totalMessages.toString(), icon: Icons.chat_bubble, color: AppColors.brandBlue),
        _MetricCard(label: "Active Ideas", value: data.activeIdeas.toString(), icon: Icons.check_circle, color: Colors.white),
      ],
    );
  }

  Widget _buildEngagementChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Engagement Per Idea", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StartLinkGlassCard(
          child: Container(
            height: 200,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: data.topIdeas.isEmpty ? [const Center(child: Text("Not enough data", style: TextStyle(color: AppColors.textSecondary)))] : 
                data.topIdeas.map((idea) => _EngagementBar(
                  label: idea.title.length > 8 ? "${idea.title.substring(0, 6)}.." : idea.title,
                  value: idea.messagesCount,
                  maxValue: data.totalMessages > 0 ? data.totalMessages : 1,
                )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopIdeasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Top Performing Ideas", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...data.topIdeas.map((idea) => _IdeaEngagementRow(idea: idea)).toList(),
      ],
    );
  }

  Widget _buildSmartInsightsSection() {
    String topIdea = data.topIdeas.isNotEmpty ? data.topIdeas.first.title : "Your startup";
    bool highInvestorInterest = data.investorInterest > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Smart Insights", style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _InsightCard(text: "Your idea '$topIdea' is trending with ${data.topIdeas.isNotEmpty ? data.topIdeas.first.messagesCount : 0} interactions! 🔥", icon: Icons.trending_up),
        if (highInvestorInterest)
          const _InsightCard(text: "Investor interest is high! Consolidating your pitch deck might be a good next step. 💼", icon: Icons.info_outline),
        if (data.totalRequests > data.totalCollaborators * 2)
          const _InsightCard(text: "High demand for collaboration. Consider expanding your team. 🚀", icon: Icons.group_add),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return StartLinkGlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _EngagementBar extends StatelessWidget {
  final String label;
  final int value;
  final int maxValue;
  const _EngagementBar({required this.label, required this.value, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final double heightFactor = (value / maxValue).clamp(0.1, 1.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value.toString(), style: const TextStyle(color: AppColors.brandCyan, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 30,
          height: 120 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.brandPurple, AppColors.brandCyan],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(color: AppColors.brandCyan.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 9)),
      ],
    );
  }
}

class _IdeaEngagementRow extends StatelessWidget {
  final IdeaPerformance idea;
  const _IdeaEngagementRow({required this.idea});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(idea.title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("${idea.collaboratorsCount} Collaborators • ${idea.requestsCount} Requests", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.brandPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: AppColors.amber, size: 14),
                const SizedBox(width: 4),
                Text("${idea.messagesCount}", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String text;
  final IconData icon;
  const _InsightCard({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.brandPurple.withValues(alpha: 0.05), Colors.transparent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandPurple.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.brandPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary, height: 1.4, fontSize: 13))),
        ],
      ),
    );
  }
}
