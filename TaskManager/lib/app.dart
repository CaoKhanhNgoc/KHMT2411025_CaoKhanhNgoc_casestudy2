import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/loading_view.dart';
import 'utils/constants.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Công Việc Nhóm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, _) {
          if (authService.isAuthenticated) {
            // Once user is logged in, profile or task list will be displayed
            return const ProfileScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
