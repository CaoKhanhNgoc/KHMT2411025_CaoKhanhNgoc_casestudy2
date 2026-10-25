import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _avatarController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    if (user != null) {
      _nameController.text = user.fullName;
      _avatarController.text = user.avatarUrl ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarController.dispose();
    super.dispose();
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
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.priorityHigh,
          ),
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
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.priorityHigh,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text('Chưa đăng nhập'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài Khoản & Cá Nhân'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryLight,
                backgroundImage:
                    (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                    ? Text(
                        user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              user.email,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Thông Tin Cá Nhân',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    if (_isEditing) ...[
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
                    ] else ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.person, color: AppColors.primary),
                        title: const Text('Họ và tên'),
                        subtitle: Text(user.fullName),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.email, color: AppColors.primary),
                        title: const Text('Email'),
                        subtitle: Text(user.email),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.primary),
                    title: const Text('Đổi mật khẩu'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.priorityHigh),
                    title: const Text(
                      'Đăng xuất',
                      style: TextStyle(color: AppColors.priorityHigh),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xác nhận đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.priorityHigh,
                                foregroundColor: Colors.white,
                              ),
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
