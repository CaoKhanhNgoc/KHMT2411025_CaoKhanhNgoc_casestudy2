import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import 'api_client.dart';

class NotificationService extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiClient.get('/notifications');
      if (response['data'] != null && response['data'] is List) {
        _notifications = (response['data'] as List)
            .map((item) => AppNotification.fromJson(item))
            .toList();
      }
      await fetchUnreadCount();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiClient.get('/notifications/unread-count');
      if (response['unreadCount'] != null) {
        _unreadCount = response['unreadCount'] as int;
        notifyListeners();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.patch('/notifications/$id/read');
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final current = _notifications[index];
        _notifications[index] = AppNotification(
          id: current.id,
          userId: current.userId,
          task: current.task,
          type: current.type,
          title: current.title,
          message: current.message,
          isRead: true,
          createdAt: current.createdAt,
        );
        if (_unreadCount > 0) _unreadCount -= 1;
        notifyListeners();
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('/notifications/read-all');
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                userId: n.userId,
                task: n.task,
                type: n.type,
                title: n.title,
                message: n.message,
                isRead: true,
                createdAt: n.createdAt,
              ))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }
}
