import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/user_portal/user_app_router.dart';

/// User Portal App - Cổng thành viên BookNest
/// Sử dụng GoRouter thay vì MaterialApp truyền thống
class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'BookNest - Cổng Thành Viên',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: userAppRouter,
    );
  }
}
