import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/loading_view.dart';
import '../tasks/task_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationService>().fetchNotifications();
    });
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'assigned':
        return Icons.assignment_ind;
      case 'shared':
        return Icons.share;
      case 'completed':
        return Icons.check_circle_outline;
      case 'reminder':
        return Icons.alarm;
      case 'updated':
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'assigned':
        return AppColors.primary;
      case 'shared':
        return AppColors.secondary;
      case 'completed':
        return AppColors.statusCompleted;
      case 'reminder':
        return AppColors.priorityHigh;
      case 'updated':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationService = context.watch<NotificationService>();
    final notifications = notificationService.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông Báo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () => notificationService.markAllAsRead(),
              child: const Text(
                'Đọc tất cả',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: notificationService.isLoading
          ? const LoadingView(message: 'Đang tải thông báo...')
          : notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: AppColors.textSecondary),
                      SizedBox(height: 12),
                      Text(
                        'Bạn không có thông báo nào',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => notificationService.fetchNotifications(),
                  child: ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      final color = _getColorForType(item.type);

                      return Container(
                        color: item.isRead ? Colors.transparent : AppColors.primaryLight.withOpacity(0.18),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(_getIconForType(item.type), color: color, size: 22),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(item.message, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(
                                DateFormatter.formatDateTime(item.createdAt),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          trailing: !item.isRead
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                )
                              : null,
                          onTap: () async {
                            if (!item.isRead) {
                              notificationService.markAsRead(item.id);
                            }
                            final taskId = item.taskId;
                            if (taskId != null && taskId.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TaskDetailScreen(taskId: taskId),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
