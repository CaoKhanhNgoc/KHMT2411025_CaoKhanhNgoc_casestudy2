import 'task.dart';

class AppNotification {
  final String id;
  final String userId;
  final dynamic task; // can be Task or Map or id String
  final String type; // 'assigned', 'shared', 'updated', 'completed', 'reminder'
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    this.task,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  String? get taskId {
    if (task == null) return null;
    if (task is Task) return (task as Task).id;
    if (task is Map) return task['_id'] ?? task['id'];
    return task.toString();
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    dynamic parsedTask;
    if (json['taskId'] != null) {
      if (json['taskId'] is Map<String, dynamic>) {
        parsedTask = Task.fromJson(json['taskId']);
      } else {
        parsedTask = json['taskId'].toString();
      }
    }

    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      task: parsedTask,
      type: json['type'] ?? 'updated',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
