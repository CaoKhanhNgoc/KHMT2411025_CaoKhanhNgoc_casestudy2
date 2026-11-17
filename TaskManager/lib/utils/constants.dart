import 'package:flutter/material.dart';

class AppConstants {
  // Use 10.0.2.2 for Android emulator, localhost for Windows/web, or your LAN IP for physical device
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  static const String fallbackLocalUrl = 'http://localhost:3000/api';

  // Task Status
  static const String statusTodo = 'todo';
  static const String statusInProgress = 'in_progress';
  static const String statusCompleted = 'completed';

  // Task Priority
  static const String priorityLow = 'low';
  static const String priorityMedium = 'medium';
  static const String priorityHigh = 'high';

  // Permissions
  static const String permViewer = 'viewer';
  static const String permEditor = 'editor';

  // SharedPreferences Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'auth_user';
  static const String keyApiUrl = 'custom_api_url';
}

/// Bảng màu Pastel hiện đại, nhẹ nhàng và thanh lịch
class AppColors {
  // Màu chủ đạo (Pastel Periwinkle / Lavender Blue)
  static const Color primary = Color(0xFF7C83FD);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryDark = Color(0xFF5A63D8);
  static const Color primaryMuted = Color(0xFF96A7FF);

  // Màu phụ (Pastel Sage Mint)
  static const Color secondary = Color(0xFF7BC0A3);
  static const Color secondaryLight = Color(0xFFE8F6EF);

  // Trạng thái Pastel (Status)
  static const Color statusTodo = Color(0xFF94A3B8);        // Pastel Slate Grey
  static const Color statusTodoBg = Color(0xFFF1F5F9);
  static const Color statusInProgress = Color(0xFF60A5FA);  // Pastel Sky Blue
  static const Color statusInProgressBg = Color(0xFFEFF6FF);
  static const Color statusCompleted = Color(0xFF34D399);   // Pastel Soft Mint
  static const Color statusCompletedBg = Color(0xFFECFDF5);

  // Mức độ ưu tiên Pastel (Priority)
  static const Color priorityLow = Color(0xFF38B2AC);       // Pastel Soft Teal
  static const Color priorityLowBg = Color(0xFFE6FFFA);
  static const Color priorityMedium = Color(0xFFF6AD55);    // Pastel Warm Apricot
  static const Color priorityMediumBg = Color(0xFFFFFAF0);
  static const Color priorityHigh = Color(0xFFFC8181);      // Pastel Soft Rose Coral
  static const Color priorityHighBg = Color(0xFFFFF5F5);

  // Nền & bề mặt (Background & Surfaces)
  static const Color background = Color(0xFFF8F9FD);        // Nền kem sáng pastel siêu mịn
  static const Color surface = Colors.white;
  static const Color cardBorder = Color(0xFFEBF0F7);        // Viền thẻ siêu mờ tinh tế
  static const Color inputFill = Color(0xFFF8FAFC);         // Nền ô nhập liệu pastel

  // Chữ & văn bản (Typography)
  static const Color textPrimary = Color(0xFF2D3748);       // Xám than đậm (thay cho đen gắt)
  static const Color textSecondary = Color(0xFF718096);     // Xám trung tính dịu mắt
  static const Color textMuted = Color(0xFFA0AEC0);         // Xám mờ

  // Màu nhấn thêm (Accent Pastels)
  static const Color accentLilac = Color(0xFFC4B5FD);       // Tím pastel
  static const Color accentPeach = Color(0xFFFDBA74);       // Đào pastel
  static const Color accentSky = Color(0xFFBAE6FD);         // Xanh da trời pastel
}
