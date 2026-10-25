import 'user.dart';

class TaskShare {
  final String id;
  final String taskId;
  final User? user;
  final String permission; // 'viewer' or 'editor'
  final User? sharedBy;
  final DateTime? createdAt;

  TaskShare({
    required this.id,
    required this.taskId,
    this.user,
    required this.permission,
    this.sharedBy,
    this.createdAt,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    User? parsedUser;
    if (json['userId'] != null && json['userId'] is Map<String, dynamic>) {
      parsedUser = User.fromJson(json['userId']);
    }

    User? parsedSharedBy;
    if (json['sharedBy'] != null && json['sharedBy'] is Map<String, dynamic>) {
      parsedSharedBy = User.fromJson(json['sharedBy']);
    }

    return TaskShare(
      id: json['_id'] ?? json['id'] ?? '',
      taskId: json['taskId'] is Map ? json['taskId']['_id'] : (json['taskId'] ?? ''),
      user: parsedUser,
      permission: json['permission'] ?? 'viewer',
      sharedBy: parsedSharedBy,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
