import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_activity.dart';
import 'api_client.dart';

class TaskService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _scope = 'all'; // 'all', 'created', 'assigned', 'shared'
  String _status = 'all';
  String _priority = 'all';
  String _searchQuery = '';
  String _sortBy = 'createdAt'; // 'createdAt', 'dueDate', 'priority'
  String _order = 'desc';

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get scope => _scope;
  String get status => _status;
  String get priority => _priority;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  String get order => _order;

  void setScope(String scope) {
    _scope = scope;
    fetchTasks();
  }

  void setFilter({String? status, String? priority}) {
    if (status != null) _status = status;
    if (priority != null) _priority = priority;
    fetchTasks();
  }

  void setSearch(String query) {
    _searchQuery = query;
    fetchTasks();
  }

  void setSorting({required String sortBy, required String order}) {
    _sortBy = sortBy;
    _order = order;
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    _setLoading(true);
    try {
      final queryParams = <String, dynamic>{
        'scope': _scope,
        'status': _status,
        'priority': _priority,
        'sortBy': _sortBy,
        'order': _order,
      };
      if (_searchQuery.trim().isNotEmpty) {
        queryParams['q'] = _searchQuery.trim();
      }

      final response = await _apiClient.get('/tasks', queryParams: queryParams);
      if (response['data'] != null && response['data'] is List) {
        _tasks = (response['data'] as List)
            .map((item) => Task.fromJson(item))
            .toList();
      } else {
        _tasks = [];
      }
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<Task> fetchTaskById(String id) async {
    final response = await _apiClient.get('/tasks/$id');
    return Task.fromJson(response['data']);
  }

  Future<Task> createTask({
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    String priority = 'medium',
    String status = 'todo',
    List<String>? assigneeIds,
    String? primaryAssigneeId,
  }) async {
    final response = await _apiClient.post('/tasks', body: {
      'title': title,
      if (description != null) 'description': description,
      if (startDate != null) 'startDate': startDate.toIso8601String(),
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'status': status,
      if (assigneeIds != null) 'assigneeIds': assigneeIds,
      if (primaryAssigneeId != null) 'primaryAssigneeId': primaryAssigneeId,
    });

    final newTask = Task.fromJson(response['data']);
    await fetchTasks();
    return newTask;
  }

  Future<Task> updateTask({
    required String id,
    required String title,
    String? description,
    DateTime? startDate,
    DateTime? dueDate,
    String? priority,
    String? status,
  }) async {
    final response = await _apiClient.put('/tasks/$id', body: {
      'title': title,
      if (description != null) 'description': description,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
    });

    final updatedTask = Task.fromJson(response['data']);
    await fetchTasks();
    return updatedTask;
  }

  Future<void> deleteTask(String id) async {
    await _apiClient.delete('/tasks/$id');
    await fetchTasks();
  }

  Future<void> updateStatus(String id, String status) async {
    await _apiClient.patch('/tasks/$id/status', body: {'status': status});
    await fetchTasks();
  }

  Future<List<TaskActivity>> fetchActivities(String taskId) async {
    final response = await _apiClient.get('/tasks/$taskId/activities');
    if (response['data'] != null && response['data'] is List) {
      return (response['data'] as List)
          .map((item) => TaskActivity.fromJson(item))
          .toList();
    }
    return [];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
