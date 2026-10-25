import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../services/notification_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/task_card.dart';
import '../notifications/notification_screen.dart';
import '../profile/profile_screen.dart';
import 'task_create_screen.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _scopes = ['all', 'created', 'assigned', 'shared'];
  final List<String> _scopeLabels = [
    'Tất cả',
    'Tôi tạo',
    'Được giao',
    'Được chia sẻ'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _scopes.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<TaskService>().setScope(_scopes[_tabController.index]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskService>().fetchTasks();
      context.read<NotificationService>().fetchUnreadCount();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterModal() {
    final taskService = context.read<TaskService>();
    String selectedStatus = taskService.status;
    String selectedPriority = taskService.priority;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Bộ Lọc Công Việc',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Trạng thái:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: selectedStatus == 'all',
                        onSelected: (_) => setModalState(() => selectedStatus = 'all'),
                      ),
                      ChoiceChip(
                        label: const Text('Chưa làm'),
                        selected: selectedStatus == 'todo',
                        onSelected: (_) => setModalState(() => selectedStatus = 'todo'),
                      ),
                      ChoiceChip(
                        label: const Text('Đang làm'),
                        selected: selectedStatus == 'in_progress',
                        onSelected: (_) => setModalState(() => selectedStatus = 'in_progress'),
                      ),
                      ChoiceChip(
                        label: const Text('Hoàn thành'),
                        selected: selectedStatus == 'completed',
                        onSelected: (_) => setModalState(() => selectedStatus = 'completed'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Mức độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.w600)),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Tất cả'),
                        selected: selectedPriority == 'all',
                        onSelected: (_) => setModalState(() => selectedPriority = 'all'),
                      ),
                      ChoiceChip(
                        label: const Text('Thấp'),
                        selected: selectedPriority == 'low',
                        onSelected: (_) => setModalState(() => selectedPriority = 'low'),
                      ),
                      ChoiceChip(
                        label: const Text('Vừa'),
                        selected: selectedPriority == 'medium',
                        onSelected: (_) => setModalState(() => selectedPriority = 'medium'),
                      ),
                      ChoiceChip(
                        label: const Text('Cao'),
                        selected: selectedPriority == 'high',
                        onSelected: (_) => setModalState(() => selectedPriority = 'high'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              selectedStatus = 'all';
                              selectedPriority = 'all';
                            });
                          },
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            taskService.setFilter(
                              status: selectedStatus,
                              priority: selectedPriority,
                            );
                            Navigator.pop(ctx);
                          },
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSortModal() {
    final taskService = context.read<TaskService>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sắp Xếp Công Việc',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Thời gian tạo mới nhất'),
                selected: taskService.sortBy == 'createdAt' && taskService.order == 'desc',
                onTap: () {
                  taskService.setSorting(sortBy: 'createdAt', order: 'desc');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Hạn hoàn thành gần nhất'),
                selected: taskService.sortBy == 'dueDate' && taskService.order == 'asc',
                onTap: () {
                  taskService.setSorting(sortBy: 'dueDate', order: 'asc');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Mức độ ưu tiên cao nhất'),
                selected: taskService.sortBy == 'priority' && taskService.order == 'desc',
                onTap: () {
                  taskService.setSorting(sortBy: 'priority', order: 'desc');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskService = context.watch<TaskService>();
    final notificationService = context.watch<NotificationService>();
    final unreadCount = notificationService.unreadCount;
    final tasks = taskService.tasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Công Việc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Lọc công việc',
            onPressed: _showFilterModal,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sắp xếp',
            onPressed: _showSortModal,
          ),
          // Notification Bell with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Thông báo',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationScreen()),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.priorityHigh,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Tài khoản & Cá nhân',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: _scopeLabels.map((label) => Tab(text: label)).toList(),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công việc...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          taskService.setSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => taskService.setSearch(val),
            ),
          ),
          // Task List
          Expanded(
            child: taskService.isLoading
                ? const LoadingView(message: 'Đang tải danh sách công việc...')
                : tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.inbox, size: 64, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            const Text(
                              'Không có công việc nào',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const TaskCreateScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo việc mới ngay'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await taskService.fetchTasks();
                          if (mounted) {
                            context.read<NotificationService>().fetchUnreadCount();
                          }
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return TaskCard(
                              task: task,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TaskDetailScreen(taskId: task.id),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TaskCreateScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
