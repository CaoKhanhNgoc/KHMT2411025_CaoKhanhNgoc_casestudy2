import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/task_share_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/user_selector.dart';

class AssignTaskScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const AssignTaskScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final TaskShareService _shareService = TaskShareService();
  List<User> _assignees = [];
  User? _primaryAssignee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final res = await _shareService.fetchAssignees(widget.taskId);
      setState(() {
        _assignees = res['assignees'] as List<User>;
        _primaryAssignee = res['primaryAssignee'] as User?;
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

  Future<void> _addAssignees() async {
    final excludedIds = _assignees.map((u) => u.id).toList();
    final selected = await showDialog<List<User>>(
      context: context,
      builder: (_) => UserSelectorDialog(
        title: 'Thêm Người Phụ Trách',
        multiSelect: true,
        excludedUserIds: excludedIds,
      ),
    );

    if (selected != null && selected.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final newIds = selected.map((u) => u.id).toList();
        await _shareService.assignUsers(
          taskId: widget.taskId,
          userIds: newIds,
          primaryAssigneeId: _primaryAssignee?.id ?? (newIds.isNotEmpty ? newIds.first : null),
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã thêm người phụ trách thành công!'),
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
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _setPrimary(String userId) async {
    try {
      await _shareService.setPrimaryAssignee(widget.taskId, userId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật người phụ trách chính!'),
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

  Future<void> _remove(String userId) async {
    try {
      await _shareService.removeAssignee(widget.taskId, userId);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy giao việc cho thành viên!'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao Công Việc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingView(message: 'Đang tải danh sách người được giao...')
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Công việc: ${widget.taskTitle}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Người Phụ Trách (${_assignees.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addAssignees,
                        icon: const Icon(Icons.person_add, size: 18),
                        label: const Text('Thêm người'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _assignees.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa giao công việc cho ai.\nNhấn nút "Thêm người" ở trên để bắt đầu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _assignees.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final user = _assignees[index];
                              final isPrimary = _primaryAssignee?.id == user.id;

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isPrimary ? Colors.amber : AppColors.primaryLight,
                                  child: Icon(
                                    isPrimary ? Icons.star : Icons.person,
                                    color: isPrimary ? Colors.white : AppColors.primaryDark,
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (isPrimary) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Chính',
                                          style: TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (val) {
                                    if (val == 'primary') {
                                      _setPrimary(user.id);
                                    } else if (val == 'remove') {
                                      _remove(user.id);
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    if (!isPrimary)
                                      const PopupMenuItem(
                                        value: 'primary',
                                        child: Row(
                                          children: [
                                            Icon(Icons.star_outline, size: 18, color: Colors.amber),
                                            SizedBox(width: 8),
                                            Text('Đặt làm phụ trách chính'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'remove',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 18, color: AppColors.priorityHigh),
                                          SizedBox(width: 8),
                                          Text('Hủy giao việc', style: TextStyle(color: AppColors.priorityHigh)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
