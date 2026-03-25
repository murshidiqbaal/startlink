import 'package:flutter/material.dart';
import 'package:startlink/core/services/supabase_client.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/debug/services/simulation_service.dart';

class SimulationDashboard extends StatefulWidget {
  const SimulationDashboard({super.key});

  @override
  State<SimulationDashboard> createState() => _SimulationDashboardState();
}

class _SimulationDashboardState extends State<SimulationDashboard> {
  late SimulationService _service;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _service = SimulationService(SupabaseService.client);
  }

  Future<void> _runAction(String name, Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Running: $name...';
    });
    try {
      await action();
      setState(() => _statusMessage = 'Success: $name');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QA / Simulation Dashboard'),
        backgroundColor: AppColors.background,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_statusMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _statusMessage!.startsWith('Error')
                      ? AppColors.rose.withValues(alpha: 0.2)
                      : AppColors.emerald.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _statusMessage!.startsWith('Error')
                        ? AppColors.rose
                        : AppColors.emerald,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
            Text(
              'User & Profile',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.brandCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Auto-Fill My Profile',
              'Sets dummy data for name, bio, skills, etc.',
              Icons.person,
              () =>
                  _runAction('Fill Profile', () => _service.autoFillProfile()),
            ),
            const SizedBox(height: 24),
            Text(
              'Idea Module',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.brandPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Post 5 Dummy Ideas',
              'Creates 5 ideas with random titles and descriptions.',
              Icons.lightbulb,
              () => _runAction('Post Ideas', () => _service.postDummyIdeas(5)),
            ),
            const SizedBox(height: 24),
            Text(
              'Collaboration',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Simulate 3 Incoming Requests',
              'Attempts to create fake users and have them apply to your ideas.',
              Icons.group_add,
              () => _runAction(
                'Incoming Requests',
                () => _service.simulateIncomingRequests(3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Investors & AI',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.emerald,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Simulate Investor Interest',
              'Creates a fake VC offering funding.',
              Icons.monetization_on,
              () => _runAction(
                'Investor Interest',
                () => _service.simulateInvestorInterest(),
              ),
            ),
            const SizedBox(height: 12),
            _buildActionTile(
              'Simulate AI Feedback',
              'Generates AI insights for your ideas.',
              Icons.psychology,
              () => _runAction(
                'AI Feedback',
                () => _service.simulateAIFeedback(),
              ),
            ),
            const SizedBox(height: 24),
            _buildNote(
              'Note: Simulating requests might fail if "auth.users" foreign key constraints are strict.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      color: AppColors.surfaceGlass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.brandCyan),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _isLoading ? null : onTap,
      ),
    );
  }

  Widget _buildNote(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary.withValues(alpha: 0.6),
        fontSize: 12,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
