import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';

class UserSelectorDialog extends StatefulWidget {
  final String title;
  final bool multiSelect;
  final List<String> excludedUserIds;

  const UserSelectorDialog({
    super.key,
    this.title = 'Chọn Người Dùng',
    this.multiSelect = false,
    this.excludedUserIds = const [],
  });

  @override
  State<UserSelectorDialog> createState() => _UserSelectorDialogState();
}

class _UserSelectorDialogState extends State<UserSelectorDialog> {
  final UserService _userService = UserService();
  final TextEditingController _searchController = TextEditingController();
  List<User> _results = [];
  final List<User> _selectedUsers = [];
  bool _isLoading = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final list = await _userService.searchUsers(query.trim());
      setState(() {
        _results = list
            .where((u) => !widget.excludedUserIds.contains(u.id))
            .toList();
      });
    } catch (_) {
      // ignore
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập tên hoặc email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: _search,
            ),
            const SizedBox(height: 12),
            if (widget.multiSelect && _selectedUsers.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedUsers.map((user) {
                  return Chip(
                    label: Text(user.fullName, style: const TextStyle(fontSize: 12)),
                    onDeleted: () {
                      setState(() => _selectedUsers.remove(user));
                    },
                  );
                }).toList(),
              ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(
                          child: Text(
                            'Không tìm thấy người dùng',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _results.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = _results[index];
                            final isSelected = _selectedUsers.any((u) => u.id == user.id);

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: Text(
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: AppColors.primaryDark),
                                ),
                              ),
                              title: Text(user.fullName),
                              subtitle: Text(user.email, style: const TextStyle(fontSize: 12)),
                              trailing: widget.multiSelect
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedUsers.add(user);
                                          } else {
                                            _selectedUsers.removeWhere((u) => u.id == user.id);
                                          }
                                        });
                                      },
                                    )
                                  : null,
                              onTap: () {
                                if (widget.multiSelect) {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedUsers.removeWhere((u) => u.id == user.id);
                                    } else {
                                      _selectedUsers.add(user);
                                    }
                                  });
                                } else {
                                  Navigator.pop(context, user);
                                }
                              },
                            );
                          },
                        ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'),
                ),
                if (widget.multiSelect)
                  ElevatedButton(
                    onPressed: _selectedUsers.isEmpty
                        ? null
                        : () => Navigator.pop(context, _selectedUsers),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Chọn (${_selectedUsers.length})'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
