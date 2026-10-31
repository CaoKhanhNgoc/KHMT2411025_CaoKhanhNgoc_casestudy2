import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/statistics_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StatisticsService _statsService = StatisticsService();
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _isEditing = false;

  Map<String, dynamic>? _taskStats;
  Map<String, dynamic>? _assignmentStats;
  Map<String, dynamic>? _deadlineStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _avatarController.text = user.avatarUrl ?? '';
    }
    _loadStatistics();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoadingStats = true);
    try {
      final taskStats = await _statsService.getTasksStatistics();
      final assignmentStats = await _statsService.getAssignmentsStatistics();
      final deadlineStats = await _statsService.getDeadlinesStatistics();
      setState(() {
        _taskStats = taskStats;
        _assignmentStats = assignmentStats;
        _deadlineStats = deadlineStats;
      });
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _saveProfile() async {
    final authService = context.read<AuthService>();
    try {
      await authService.updateProfile(
        fullName: _nameController.text.trim(),
        avatarUrl: _avatarController.text.trim(),
      );
      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật hồ sơ thành công!'),
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

  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Đổi Mật Khẩu'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                  validator: Validators.validatePassword,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Xác nhận mật khẩu mới'),
                  validator: (val) =>
                      Validators.validateConfirmPassword(val, newPassController.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                try {
                  await context.read<AuthService>().changePassword(
                        currentPassword: currentPassController.text,
                        newPassword: newPassController.text,
                      );
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đổi mật khẩu thành công!'),
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
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _showServerConfigDialog() {
    final urlController = TextEditingController(text: ApiClient().baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cấu Hình Địa Chỉ Máy Chủ API'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gợi ý:\n• Android Emulator: http://10.0.2.2:3000/api\n• Máy ảo/máy thật cùng Wi-Fi: http://<IP-may-tinh>:3000/api\n• Windows/Web: http://localhost:3000/api',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Base API URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () {
              ApiClient().setBaseUrl(urlController.text.trim());
              Navigator.pop(ctx);
              _loadStatistics();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã cập nhật URL kết nối API!')),
              );
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Chưa đăng nhập'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá Nhân & Thống Kê'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới thống kê',
            onPressed: _loadStatistics,
          ),
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            tooltip: _isEditing ? 'Đóng' : 'Sửa hồ sơ',
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _nameController.text = user.fullName;
                  _avatarController.text = user.avatarUrl ?? '';
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Profile Edit Form or Info
            if (_isEditing)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Họ và tên'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _avatarController,
                        decoration: const InputDecoration(labelText: 'Đường dẫn ảnh đại diện (URL)'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: authService.isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Lưu Thay Đổi'),
                      ),
                    ],
                  ),
                ),
              ),

            // Statistics Section
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.bar_chart, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Thống Kê Công Việc Theo Trạng Thái',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (_isLoadingStats)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_taskStats != null) ...[
                      Row(
                        children: [
                          _buildStatCard('Tổng số', '${_taskStats!['total'] ?? 0}', AppColors.primary, Icons.all_inbox),
                          const SizedBox(width: 6),
                          _buildStatCard('Chưa làm', '${_taskStats!['todo'] ?? 0}', AppColors.statusTodo, Icons.pending_actions),
                          const SizedBox(width: 6),
                          _buildStatCard('Đang làm', '${_taskStats!['inProgress'] ?? 0}', AppColors.statusInProgress, Icons.run_circle_outlined),
                          const SizedBox(width: 6),
                          _buildStatCard('Hoàn thành', '${_taskStats!['completed'] ?? 0}', AppColors.statusCompleted, Icons.check_circle_outline),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ((_taskStats!['completionRate'] ?? 0) as num) / 100,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.statusCompleted,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tỷ lệ hoàn thành: ${_taskStats!['completionRate'] ?? 0}%',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Assignments & Deadlines Stats
            if (!_isLoadingStats && _assignmentStats != null && _deadlineStats != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.group_work, color: AppColors.secondary),
                          SizedBox(width: 8),
                          Text(
                            'Vai Trò & Phân Công',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          _buildStatCard('Tôi tạo', '${_assignmentStats!['createdCount'] ?? 0}', Colors.purple, Icons.create),
                          const SizedBox(width: 6),
                          _buildStatCard('Được giao', '${_assignmentStats!['assignedCount'] ?? 0}', Colors.indigo, Icons.assignment_ind),
                          const SizedBox(width: 6),
                          _buildStatCard('Phụ trách chính', '${_assignmentStats!['primaryCount'] ?? 0}', Colors.amber.shade800, Icons.star),
                          const SizedBox(width: 6),
                          _buildStatCard('Được chia sẻ', '${_assignmentStats!['sharedCount'] ?? 0}', AppColors.secondary, Icons.share),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.access_time_filled, color: AppColors.priorityHigh),
                          SizedBox(width: 8),
                          Text(
                            'Theo Dõi Tiến Độ & Hạn Chót',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          _buildStatCard('Đã quá hạn', '${_deadlineStats!['overdueCount'] ?? 0}', AppColors.priorityHigh, Icons.warning_amber),
                          const SizedBox(width: 8),
                          _buildStatCard('Sắp đến hạn (24h)', '${_deadlineStats!['dueSoonCount'] ?? 0}', Colors.orange, Icons.alarm),
                          const SizedBox(width: 8),
                          _buildStatCard('Đúng hạn', '${_deadlineStats!['onTrackCount'] ?? 0}', AppColors.statusCompleted, Icons.timer),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Settings & Actions
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_ethernet, color: AppColors.primary),
                    title: const Text('Cấu hình địa chỉ máy chủ API'),
                    subtitle: Text(ApiClient().baseUrl, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showServerConfigDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Đổi mật khẩu'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.priorityHigh),
                    title: const Text('Đăng xuất', style: TextStyle(color: AppColors.priorityHigh)),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.priorityHigh, foregroundColor: Colors.white),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await authService.logout();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
