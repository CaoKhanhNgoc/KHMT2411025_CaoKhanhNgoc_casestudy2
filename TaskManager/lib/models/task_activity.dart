import 'user.dart';

class TaskActivity {
  final String id;
  final String taskId;
  final User? user;
  final String action;
  final Map<String, dynamic> details;
  final DateTime? createdAt;

  TaskActivity({
    required this.id,
    required this.taskId,
    this.user,
    required this.action,
    this.details = const {},
    this.createdAt,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    User? parsedUser;
    if (json['userId'] != null && json['userId'] is Map<String, dynamic>) {
      parsedUser = User.fromJson(json['userId']);
    }

    return TaskActivity(
      id: json['_id'] ?? json['id'] ?? '',
      taskId: json['taskId'] is Map ? json['taskId']['_id'] : (json['taskId'] ?? ''),
      user: parsedUser,
      action: json['action'] ?? '',
      details: json['details'] != null && json['details'] is Map
          ? Map<String, dynamic>.from(json['details'])
          : {},
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
