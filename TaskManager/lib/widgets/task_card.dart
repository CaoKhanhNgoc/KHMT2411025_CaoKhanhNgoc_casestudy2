import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import 'status_badge.dart';
import 'priority_badge.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskCard({super.key, required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOverdue = DateFormatter.isOverdue(task.dueDate, task.status);
    final isDueSoon = DateFormatter.isDueSoon(task.dueDate, task.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: task.status == AppConstants.statusCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.status == AppConstants.statusCompleted
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: task.status),
                ],
              ),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  PriorityBadge(priority: task.priority),
                  const Spacer(),
                  if (task.dueDate != null) ...[
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isOverdue
                          ? AppColors.priorityHigh
                          : (isDueSoon ? AppColors.priorityMedium : AppColors.textSecondary),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatDate(task.dueDate),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isOverdue || isDueSoon ? FontWeight.bold : FontWeight.normal,
                        color: isOverdue
                            ? AppColors.priorityHigh
                            : (isDueSoon ? AppColors.priorityMedium : AppColors.textSecondary),
                      ),
                    ),
                  ],
                ],
              ),
              if (task.assignees.isNotEmpty || task.primaryAssignee != null) ...[
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        task.primaryAssignee != null
                            ? 'Chính: ${task.primaryAssignee!.fullName}${task.assignees.length > 1 ? " (+${task.assignees.length - 1})" : ""}'
                            : '${task.assignees.length} người phụ trách',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
