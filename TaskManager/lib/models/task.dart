import 'user.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final User? createdBy;
  final List<User> assignees;
  final User? primaryAssignee;
  final DateTime? startDate;
  final DateTime? dueDate;
  final String priority; // 'low', 'medium', 'high'
  final String status;   // 'todo', 'in_progress', 'completed'
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Permissions info from backend response
  final String? userAccess; // 'owner', 'assignee', 'editor', 'viewer'
  final bool isOwner;
  final bool canEdit;
  final bool canDelete;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.createdBy,
    this.assignees = const [],
    this.primaryAssignee,
    this.startDate,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'todo',
    this.createdAt,
    this.updatedAt,
    this.userAccess,
    this.isOwner = false,
    this.canEdit = false,
    this.canDelete = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    List<User> parsedAssignees = [];
    if (json['assigneeIds'] != null && json['assigneeIds'] is List) {
      parsedAssignees = (json['assigneeIds'] as List)
          .where((item) => item is Map<String, dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    User? parsedCreatedBy;
    if (json['createdBy'] != null && json['createdBy'] is Map<String, dynamic>) {
      parsedCreatedBy = User.fromJson(json['createdBy']);
    }

    User? parsedPrimaryAssignee;
    if (json['primaryAssigneeId'] != null &&
        json['primaryAssigneeId'] is Map<String, dynamic>) {
      parsedPrimaryAssignee = User.fromJson(json['primaryAssigneeId']);
    }

    return Task(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: parsedCreatedBy,
      assignees: parsedAssignees,
      primaryAssignee: parsedPrimaryAssignee,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      priority: json['priority'] ?? 'medium',
      status: json['status'] ?? 'todo',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      userAccess: json['userAccess'],
      isOwner: json['isOwner'] ?? false,
      canEdit: json['canEdit'] ?? false,
      canDelete: json['canDelete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority,
      'status': status,
    };
  }
}
