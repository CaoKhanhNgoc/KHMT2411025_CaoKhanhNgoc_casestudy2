import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../models/task_activity.dart';
import '../../services/statistics_service.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';
import '../assignment/assign_task_screen.dart';
import '../sharing/task_sharing_screen.dart';
import 'task_edit_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final StatisticsService _statsService = StatisticsService();
  Task? _task;
  List<TaskActivity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskData();
  }

  Future<void> _loadTaskData() async {
    setState(() => _isLoading = true);
    try {
      final taskService = context.read<TaskService>();
      final task = await taskService.fetchTaskById(widget.taskId);
      final activities = await taskService.fetchActivities(widget.taskId);
      setState(() {
        _task = task;
        _activities = activities;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.priorityHigh),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await context.read<TaskService>().updateStatus(widget.taskId, status);
      await _loadTaskData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật trạng thái thành công!'),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.priorityHigh),
        );
      }
    }
  }

  Future<void> _deleteTask() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa công việc này không? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await context.read<TaskService>().deleteTask(widget.taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa công việc thành công!'), backgroundColor: AppColors.statusCompleted),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.priorityHigh),
          );
        }
      }
    }
  }

  void _showEmailLogsDialog() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return FutureBuilder<List<dynamic>>(
          future: _statsService.getTaskEmailLogs(widget.taskId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                title: Text('Lịch Sử Gửi Email'),
                content: SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            final logs = snapshot.data ?? [];

            return AlertDialog(
              title: const Text('Lịch Sử Gửi Email'),
              content: SizedBox(
                width: double.maxFinite,
                child: logs.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Chưa có email nào được gửi cho công việc này'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: logs.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final isSent = log['status'] == 'sent';
                          final isFailed = log['status'] == 'failed';

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              isSent ? Icons.check_circle : (isFailed ? Icons.error : Icons.access_time),
                              color: isSent ? AppColors.statusCompleted : (isFailed ? AppColors.priorityHigh : Colors.amber),
                            ),
                            title: Text(log['subject'] ?? 'Email thông báo', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tới: ${log['recipientEmail']}', style: const TextStyle(fontSize: 12)),
                                Text('Trạng thái: ${log['status']} (Lần thử: ${log['attempts']})', style: const TextStyle(fontSize: 11)),
                                if (log['errorMessage'] != null)
                                  Text('Lỗi: ${log['errorMessage']}', style: const TextStyle(fontSize: 11, color: AppColors.priorityHigh)),
                              ],
                            ),
                            trailing: isFailed
                                ? IconButton(
                                    icon: const Icon(Icons.refresh, color: AppColors.primary),
                                    tooltip: 'Thử gửi lại',
                                    onPressed: () async {
                                      try {
                                        await _statsService.retryEmail(log['_id']);
                                        Navigator.pop(ctx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Đang thử gửi lại email...')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.priorityHigh),
                                        );
                                      }
                                    },
                                  )
                                : null,
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi Tiết Công Việc')),
        body: const LoadingView(message: 'Đang tải chi tiết công việc...'),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi Tiết Công Việc')),
        body: const Center(child: Text('Không tìm thấy thông tin công việc')),
      );
    }

    final task = _task!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Công Việc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read_outlined),
            tooltip: 'Lịch sử email',
            onPressed: _showEmailLogsDialog,
          ),
          if (task.canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Chỉnh sửa',
              onPressed: () async {
                final result = await Navigator.push<Task>(
                  context,
                  MaterialPageRoute(builder: (_) => TaskEditScreen(task: task)),
                );
                if (result != null) {
                  _loadTaskData();
                }
              },
            ),
          if (task.canDelete)
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Xóa công việc',
              onPressed: _deleteTask,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title & Badges
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        StatusBadge(status: task.status),
                        const SizedBox(width: 8),
                        PriorityBadge(priority: task.priority),
                        const Spacer(),
                        if (task.userAccess != null)
                          Chip(
                            label: Text(
                              'Quyền: ${task.userAccess}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Actions: Giao việc & Chia sẻ
            Row(
              children: [
                if (task.canEdit)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssignTaskScreen(
                              taskId: task.id,
                              taskTitle: task.title,
                            ),
                          ),
                        );
                        _loadTaskData();
                      },
                      icon: const Icon(Icons.assignment_ind),
                      label: const Text('Giao việc'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (task.canEdit && task.isOwner) const SizedBox(width: 12),
                if (task.isOwner)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskSharingScreen(
                              taskId: task.id,
                              taskTitle: task.title,
                            ),
                          ),
                        );
                        _loadTaskData();
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('Chia sẻ quyền'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mô tả', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    Text(
                      task.description.isEmpty ? 'Không có mô tả nào' : task.description,
                      style: TextStyle(
                        color: task.description.isEmpty ? AppColors.textSecondary : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Timeline & People
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today, color: AppColors.primary),
                      title: const Text('Thời gian thực hiện'),
                      subtitle: Text(
                        'Bắt đầu: ${DateFormatter.formatDate(task.startDate)}  •  Hạn chót: ${DateFormatter.formatDate(task.dueDate)}',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person, color: AppColors.primary),
                      title: const Text('Người tạo'),
                      subtitle: Text(task.createdBy?.fullName ?? 'Không rõ'),
                    ),
                    if (task.primaryAssignee != null) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: const Text('Người phụ trách chính'),
                        subtitle: Text(task.primaryAssignee!.fullName),
                      ),
                    ],
                    if (task.assignees.isNotEmpty) ...[
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.group, color: AppColors.secondary),
                        title: const Text('Những người được giao'),
                        subtitle: Text(task.assignees.map((u) => u.fullName).join(', ')),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Status changer buttons (if canEdit)
            if (task.canEdit)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chuyển Trạng Thái Nhanh', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: task.status == 'todo' ? AppColors.statusTodo.withOpacity(0.2) : null,
                              ),
                              onPressed: () => _updateStatus('todo'),
                              child: const Text('Chưa làm'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: task.status == 'in_progress' ? AppColors.statusInProgress.withOpacity(0.2) : null,
                              ),
                              onPressed: () => _updateStatus('in_progress'),
                              child: const Text('Đang làm'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: task.status == 'completed' ? AppColors.statusCompleted.withOpacity(0.2) : null,
                              ),
                              onPressed: () => _updateStatus('completed'),
                              child: const Text('Hoàn thành'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Activity Log
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lịch Sử Hoạt Động', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Divider(),
                    if (_activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('Chưa có lịch sử hoạt động', style: TextStyle(color: AppColors.textSecondary)),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _activities.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final act = _activities[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history, size: 20, color: AppColors.primary),
                            title: Text(act.action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            subtitle: Text(
                              'Thực hiện bởi: ${act.user?.fullName ?? "Hệ thống"} • ${DateFormatter.formatDateTime(act.createdAt)}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
