import 'api_client.dart';

class StatisticsService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getTasksStatistics() async {
    final response = await _apiClient.get('/statistics/tasks');
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getAssignmentsStatistics() async {
    final response = await _apiClient.get('/statistics/assignments');
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDeadlinesStatistics() async {
    final response = await _apiClient.get('/statistics/deadlines');
    return response['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTaskEmailLogs(String taskId) async {
    final response = await _apiClient.get('/tasks/$taskId/email-logs');
    return (response['data'] as List?) ?? [];
  }

  Future<void> retryEmail(String emailLogId) async {
    await _apiClient.post('/email-logs/$emailLogId/retry');
  }
}
