import 'package:startlink/features/analytics/domain/models/analytics_data.dart';
import 'package:startlink/features/analytics/domain/models/idea_performance.dart';
import 'package:startlink/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final SupabaseClient _supabase;

  AnalyticsRepositoryImpl(this._supabase);

  @override
  Future<AnalyticsData> fetchInnovatorAnalytics(String innovatorId) async {
    final results = await Future.wait([
      _getTotalIdeas(innovatorId),
      _getTotalRequests(innovatorId),
      _getAcceptedCollaborators(innovatorId),
      _getInvestorInterest(innovatorId),
      _getTotalMessages(innovatorId),
      _getActiveIdeas(innovatorId),
      _getTopIdeas(innovatorId),
    ]);

    return AnalyticsData(
      totalIdeas: results[0] as int,
      totalRequests: results[1] as int,
      totalCollaborators: results[2] as int,
      investorInterest: results[3] as int,
      totalMessages: results[4] as int,
      activeIdeas: results[5] as int,
      topIdeas: results[6] as List<IdeaPerformance>,
    );
  }

  Future<int> _getTotalIdeas(String innovatorId) async {
    final response = await _supabase
        .from('ideas')
        .select('id')
        .eq('owner_id', innovatorId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> _getTotalRequests(String innovatorId) async {
    final response = await _supabase
        .from('collaboration_requests')
        .select('request_id')
        .eq('innovator_id', innovatorId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> _getAcceptedCollaborators(String innovatorId) async {
    final response = await _supabase
        .from('idea_collaborators')
        .select('id, ideas!inner(owner_id)')
        .eq('ideas.owner_id', innovatorId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> _getInvestorInterest(String innovatorId) async {
    final response = await _supabase
        .from('investor_chats')
        .select('id')
        .eq('innovator_id', innovatorId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> _getTotalMessages(String innovatorId) async {
    final response = await _supabase
        .from('team_messages')
        .select('id, teams!inner(idea_id, ideas!inner(owner_id))')
        .eq('teams.ideas.owner_id', innovatorId)
        .count(CountOption.exact);
    return response.count;
  }

  Future<int> _getActiveIdeas(String innovatorId) async {
    final response = await _supabase
        .from('ideas')
        .select('id')
        .eq('owner_id', innovatorId)
        .eq('status', 'active')
        .count(CountOption.exact);
    return response.count;
  }

  Future<List<IdeaPerformance>> _getTopIdeas(String innovatorId) async {
    final ideasResponse = await _supabase
        .from('ideas')
        .select('id, title')
        .eq('owner_id', innovatorId);

    final List<Map<String, dynamic>> ideas = List<Map<String, dynamic>>.from(
      ideasResponse as List,
    );
    List<IdeaPerformance> performances = [];

    for (var idea in ideas) {
      final ideaId = idea['id'];

      final collabCountRes = await _supabase
          .from('idea_collaborators')
          .select('id')
          .eq('idea_id', ideaId)
          .count(CountOption.exact);
      final requestCountRes = await _supabase
          .from('collaboration_requests')
          .select('id')
          .eq('idea_id', ideaId)
          .count(CountOption.exact);
      // Count messages via teams for this idea
      final msgCountRes = await _supabase
          .from('team_messages')
          .select('id, teams!inner(idea_id)')
          .eq('teams.idea_id', ideaId)
          .count(CountOption.exact);

      performances.add(
        IdeaPerformance(
          id: ideaId,
          title: idea['title'],
          collaboratorsCount: collabCountRes.count,
          requestsCount: requestCountRes.count,
          messagesCount: msgCountRes.count,
        ),
      );
    }

    performances.sort((a, b) => b.messagesCount.compareTo(a.messagesCount));
    return performances.take(5).toList();
  }
}
