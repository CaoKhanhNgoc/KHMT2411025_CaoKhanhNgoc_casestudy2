import 'package:flutter/material.dart';
import '../../models/task_share.dart';
import '../../models/user.dart';
import '../../services/task_share_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/user_selector.dart';

class TaskSharingScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const TaskSharingScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  final TaskShareService _shareService = TaskShareService();
  List<TaskShare> _shares = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShares();
  }

  Future<void> _loadShares() async {
    setState(() => _isLoading = true);
    try {
      final list = await _shareService.fetchShares(widget.taskId);
      setState(() => _shares = list);
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

  Future<void> _addNewShare() async {
    final excludedIds = _shares.where((s) => s.user != null).map((s) => s.user!.id).toList();
    final user = await showDialog<User>(
      context: context,
      builder: (_) => UserSelectorDialog(
        title: 'Chia Sẻ Với Người Dùng',
        multiSelect: false,
        excludedUserIds: excludedIds,
      ),
    );

    if (user != null) {
      // Pick permission (viewer or editor)
      String permission = 'viewer';
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Chia sẻ với ${user.fullName}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text('Chỉ xem (Viewer)'),
                      subtitle: const Text('Người dùng chỉ được đọc thông tin'),
                      value: 'viewer',
                      groupValue: permission,
                      onChanged: (val) => setDialogState(() => permission = val!),
                    ),
                    RadioListTile<String>(
                      title: const Text('Chỉnh sửa (Editor)'),
                      subtitle: const Text('Người dùng có quyền cập nhật công việc'),
                      value: 'editor',
                      groupValue: permission,
                      onChanged: (val) => setDialogState(() => permission = val!),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (confirmed == true) {
        setState(() => _isLoading = true);
        try {
          await _shareService.shareTask(
            taskId: widget.taskId,
            userId: user.id,
            permission: permission,
          );
          await _loadShares();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã chia sẻ công việc thành công!'),
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
  }

  Future<void> _updatePermission(TaskShare share, String newPermission) async {
    try {
      await _shareService.updateSharePermission(
        taskId: widget.taskId,
        shareId: share.id,
        permission: newPermission,
      );
      await _loadShares();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã cập nhật quyền truy cập!'),
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

  Future<void> _revokeShare(TaskShare share) async {
    try {
      await _shareService.revokeShare(taskId: widget.taskId, shareId: share.id);
      await _loadShares();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã thu hồi quyền chia sẻ!'),
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
        title: const Text('Quản Lý Chia Sẻ'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingView(message: 'Đang tải danh sách chia sẻ...')
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: AppColors.secondary.withOpacity(0.15),
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
                        'Được Chia Sẻ (${_shares.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addNewShare,
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Chia sẻ mới'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _shares.isEmpty
                        ? const Center(
                            child: Text(
                              'Công việc này chưa được chia sẻ với ai.\nNhấn nút "Chia sẻ mới" để cấp quyền xem hoặc sửa.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _shares.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final share = _shares[index];
                              final user = share.user;
                              final isEditor = share.permission == 'editor';

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isEditor ? AppColors.primaryLight : Colors.grey.shade200,
                                  child: Icon(
                                    isEditor ? Icons.edit_note : Icons.visibility,
                                    color: isEditor ? AppColors.primaryDark : AppColors.textSecondary,
                                  ),
                                ),
                                title: Text(
                                  user?.fullName ?? 'Người dùng',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  user?.email ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Chip(
                                      label: Text(
                                        isEditor ? 'Editor' : 'Viewer',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isEditor ? AppColors.primary : AppColors.textSecondary,
                                        ),
                                      ),
                                      backgroundColor: isEditor
                                          ? AppColors.primaryLight.withOpacity(0.5)
                                          : Colors.grey.shade200,
                                      padding: EdgeInsets.zero,
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'toggle_perm') {
                                          _updatePermission(share, isEditor ? 'viewer' : 'editor');
                                        } else if (val == 'revoke') {
                                          _revokeShare(share);
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        PopupMenuItem(
                                          value: 'toggle_perm',
                                          child: Text(isEditor ? 'Đổi thành Viewer (chỉ xem)' : 'Đổi thành Editor (chỉnh sửa)'),
                                        ),
                                        const PopupMenuItem(
                                          value: 'revoke',
                                          child: Text('Thu hồi quyền', style: TextStyle(color: AppColors.priorityHigh)),
                                        ),
                                      ],
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
