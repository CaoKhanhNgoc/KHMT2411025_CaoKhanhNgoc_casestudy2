import 'package:flutter/foundation.dart';
import '../models/task_share.dart';
import '../models/user.dart';
import 'api_client.dart';

class TaskShareService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> fetchAssignees(String taskId) async {
    final response = await _apiClient.get('/tasks/$taskId/assignees');
    final data = response['data'];

    List<User> assignees = [];
    if (data['assignees'] != null && data['assignees'] is List) {
      assignees = (data['assignees'] as List)
          .map((item) => User.fromJson(item))
          .toList();
    }

    User? primaryAssignee;
    if (data['primaryAssignee'] != null && data['primaryAssignee'] is Map<String, dynamic>) {
      primaryAssignee = User.fromJson(data['primaryAssignee']);
    }

    return {
      'assignees': assignees,
      'primaryAssignee': primaryAssignee,
    };
  }

  Future<void> assignUsers({
    required String taskId,
    required List<String> userIds,
    String? primaryAssigneeId,
  }) async {
    await _apiClient.post('/tasks/$taskId/assignees', body: {
      'userIds': userIds,
      if (primaryAssigneeId != null) 'primaryAssigneeId': primaryAssigneeId,
    });
    notifyListeners();
  }

  Future<void> setPrimaryAssignee(String taskId, String userId) async {
    await _apiClient.patch('/tasks/$taskId/assignees/$userId');
    notifyListeners();
  }

  Future<void> removeAssignee(String taskId, String userId) async {
    await _apiClient.delete('/tasks/$taskId/assignees/$userId');
    notifyListeners();
  }

  Future<List<TaskShare>> fetchShares(String taskId) async {
    final response = await _apiClient.get('/tasks/$taskId/shares');
    if (response['data'] != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => TaskShare.fromJson(item))
          .toList();
    }
    return [];
  }

  Future<void> shareTask({
    required String taskId,
    required String userId,
    required String permission,
  }) async {
    await _apiClient.post('/tasks/$taskId/shares', body: {
      'userId': userId,
      'permission': permission,
    });
    notifyListeners();
  }

  Future<void> updateSharePermission({
    required String taskId,
    required String shareId,
    required String permission,
  }) async {
    await _apiClient.patch('/tasks/$taskId/shares/$shareId', body: {
      'permission': permission,
    });
    notifyListeners();
  }

  Future<void> revokeShare({
    required String taskId,
    required String shareId,
  }) async {
    await _apiClient.delete('/tasks/$taskId/shares/$shareId');
    notifyListeners();
  }
}
