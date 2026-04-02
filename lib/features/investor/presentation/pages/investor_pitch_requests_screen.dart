import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/auth/domain/repository/auth_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/pitch/pitch_bloc.dart';
import '../bloc/pitch/pitch_event.dart';
import '../bloc/pitch/pitch_state.dart';
import '../../domain/entities/pitch_request.dart';
import 'investor_idea_detail_screen.dart';

class InvestorPitchRequestsScreen extends StatefulWidget {
  const InvestorPitchRequestsScreen({super.key});

  @override
  State<InvestorPitchRequestsScreen> createState() => _InvestorPitchRequestsScreenState();
}

class _InvestorPitchRequestsScreenState extends State<InvestorPitchRequestsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    final userId = context.read<AuthRepository>().currentUser?.id;
    if (userId != null) {
      context.read<PitchBloc>().add(LoadInvestorPitchRequests(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: const Text('Pitch Requests', style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: AppColors.brandPurple,
            labelColor: AppColors.brandPurple,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: BlocBuilder<PitchBloc, PitchState>(
          builder: (context, state) {
            if (state is PitchLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.brandPurple));
            } else if (state is InvestorPitchRequestsLoaded) {
              final pending = state.requests.where((r) => r.status == PitchStatus.pending).toList();
              final completed = state.requests.where((r) => r.status != PitchStatus.pending).toList();

              return TabBarView(
                children: [
                  _buildRequestList(pending, isPending: true),
                  _buildRequestList(completed, isPending: false),
                ],
              );
            } else if (state is PitchError) {
              return Center(child: Text(state.message, style: const TextStyle(color: AppColors.rose)));
            }
            return const Center(child: Text('Checking requests...', style: TextStyle(color: AppColors.textSecondary)));
          },
        ),
      ),
    );
  }

  Widget _buildRequestList(List<PitchRequest> requests, {required bool isPending}) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPending ? Icons.hourglass_empty_rounded : Icons.history_rounded,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'No pending requests' : 'No completed requests',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(PitchRequest request) {
    final statusColor = _getStatusColor(request.status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (_) => InvestorIdeaDetailScreen(ideaId: request.ideaId))
        ).then((_) => _loadRequests()),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      request.ideaTitle ?? 'Unknown Idea',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(request.status, statusColor),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Requested on ${_formatDate(request.createdAt)}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              if (request.status == PitchStatus.approved) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleDownload(request.pitchDeckUrl),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download Pitch Deck'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PitchStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(PitchStatus status) {
    switch (status) {
      case PitchStatus.approved:
        return AppColors.emerald;
      case PitchStatus.rejected:
        return AppColors.rose;
      default:
        return AppColors.amber;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleDownload(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
