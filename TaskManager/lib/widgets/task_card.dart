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
    final isCompleted = task.status == AppConstants.statusCompleted;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? AppColors.cardBorder
              : (isOverdue
                  ? AppColors.priorityHigh.withValues(alpha: 0.3)
                  : AppColors.cardBorder),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          letterSpacing: 0.1,
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
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.35,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? AppColors.priorityHighBg
                              : (isDueSoon
                                  ? AppColors.priorityMediumBg
                                  : AppColors.inputFill),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 11,
                              color: isOverdue
                                  ? AppColors.priorityHigh
                                  : (isDueSoon
                                      ? AppColors.priorityMedium
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.formatDate(task.dueDate),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isOverdue || isDueSoon
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isOverdue
                                    ? AppColors.priorityHigh
                                    : (isDueSoon
                                        ? AppColors.priorityMedium
                                        : AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (task.assignees.isNotEmpty || task.primaryAssignee != null) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_outline_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          task.primaryAssignee != null
                              ? 'Chính: ${task.primaryAssignee!.fullName}${task.assignees.length > 1 ? " (+${task.assignees.length - 1})" : ""}'
                              : '${task.assignees.length} người phụ trách',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
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
      ),
    );
  }
}
