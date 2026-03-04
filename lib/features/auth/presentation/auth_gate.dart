import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/supabase_auth_provider.dart';
import '../../home/presentation/home_page.dart';
import 'supabase_login_page.dart';

/// Widget that handles authentication state and routing.
///
/// Shows [SupabaseLoginPage] if user is not authenticated.
/// Shows [HomePage] if user is authenticated.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Nếu đang loading, hiển thị màn hình loading
    if (authState.isLoading) {
      return const _LoadingScreen();
    }

    // Kiểm tra đăng nhập
    if (authState.isLoggedIn) {
      return const HomePage();
    } else {
      return const SupabaseLoginPage();
    }
  }
}

/// Loading screen while checking auth state.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.local_library_rounded,
                size: 48,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // App name
            Text(
              'BookNest',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),

            // Loading indicator
            const CircularProgressIndicator(),
            const SizedBox(height: 16),

            Text(
              'Đang tải...',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
