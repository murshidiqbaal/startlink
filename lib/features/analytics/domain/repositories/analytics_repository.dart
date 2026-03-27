import '../models/analytics_data.dart';

abstract class AnalyticsRepository {
  Future<AnalyticsData> fetchInnovatorAnalytics(String innovatorId);
}
