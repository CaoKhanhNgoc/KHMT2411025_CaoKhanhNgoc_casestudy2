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

class AppColors {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);
  static const Color primaryDark = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF26A69A);

  static const Color statusTodo = Color(0xFF757575);
  static const Color statusInProgress = Color(0xFF0288D1);
  static const Color statusCompleted = Color(0xFF388E3C);

  static const Color priorityLow = Color(0xFF4CAF50);
  static const Color priorityMedium = Color(0xFFFFA000);
  static const Color priorityHigh = Color(0xFFD32F2F);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
}
