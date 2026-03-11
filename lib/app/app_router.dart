import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/unified_auth_provider.dart';

// ==================== ADMIN PAGES ====================
import '../features/home/presentation/admin_main_page.dart';

// ==================== AUTH PAGES ====================
import '../features/auth/presentation/unified_login_page.dart';
import '../features/user_portal/presentation/auth/user_register_page.dart';

// ==================== USER PORTAL PAGES ====================
import '../features/user_portal/presentation/shell/user_main_shell.dart';
import '../features/user_portal/presentation/home/user_home_page.dart';
import '../features/user_portal/presentation/book/user_book_detail_page.dart';
import '../features/user_portal/presentation/book/buy_checkout_page.dart';
import '../features/user_portal/presentation/book/borrow_checkout_page.dart';
import '../features/user_portal/presentation/social/social_feed_page.dart';
import '../features/user_portal/presentation/social/user_review_page.dart';
import '../features/user_portal/presentation/social/user_public_profile_page.dart';
import '../features/user_portal/presentation/qr/qr_scanner_page.dart';
import '../features/user_portal/presentation/profile/user_profile_page.dart';
import '../features/user_portal/presentation/profile/purchase_history_page.dart';
import '../features/user_portal/presentation/profile/borrow_history_page.dart';
import '../features/user_portal/presentation/profile/wallet_page.dart';

// ============================================================================
// Unified App Router
// Hợp nhất routing cho Admin, Librarian và Member
// ============================================================================

/// Navigator keys
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _userShellNavigatorKey = GlobalKey<NavigatorState>();

/// Provider cho GoRouter (cần WidgetRef để redirect theo auth state)
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    
    // ==================== REDIRECT LOGIC ====================
    redirect: (context, state) {
      final authState = ref.read(unifiedAuthProvider);
      final isLoggedIn = authState.isLoggedIn;
      final currentPath = state.matchedLocation;

      // Các route không cần đăng nhập
      final publicRoutes = ['/login', '/register'];
      final isPublicRoute = publicRoutes.contains(currentPath);

      // Chưa đăng nhập mà truy cập route protected -> về login
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // Đã đăng nhập mà vào login/register -> redirect theo role
      if (isLoggedIn && isPublicRoute) {
        final role = authState.currentUser?.role;
        if (role == UserRole.member) {
          return '/user/home';
        } else {
          return '/admin';
        }
      }

      // Không redirect
      return null;
    },

    routes: [
      // ==================== AUTH ROUTES ====================
      GoRoute(
        path: '/login',
        builder: (context, state) => const UnifiedLoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const UserRegisterPage(),
      ),

      // ==================== ADMIN ROUTES ====================
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminMainPage(),
      ),

      // ==================== USER PORTAL SHELL ====================
      ShellRoute(
        navigatorKey: _userShellNavigatorKey,
        builder: (context, state, child) => UserMainShell(child: child),
        routes: [
          GoRoute(
            path: '/user/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserHomePage(),
            ),
          ),
          GoRoute(
            path: '/user/social',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SocialFeedPage(),
            ),
          ),
          GoRoute(
            path: '/user/scan',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: QrScannerPage(),
            ),
          ),
          GoRoute(
            path: '/user/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: UserProfilePage(),
            ),
          ),
        ],
      ),

      // ==================== BOOK DETAIL & CHECKOUT ====================
      GoRoute(
        path: '/user/book/:bookId',
        builder: (context, state) => UserBookDetailPage(
          bookId: state.pathParameters['bookId']!,
        ),
        routes: [
          GoRoute(
            path: 'buy',
            builder: (context, state) => BuyCheckoutPage(
              bookId: state.pathParameters['bookId']!,
            ),
          ),
          GoRoute(
            path: 'borrow',
            builder: (context, state) => BorrowCheckoutPage(
              bookId: state.pathParameters['bookId']!,
            ),
          ),
        ],
      ),

      // ==================== SOCIAL SUB-PAGES ====================
      GoRoute(
        path: '/user/social/review/:reviewId',
        builder: (context, state) => UserReviewPage(
          reviewId: state.pathParameters['reviewId']!,
        ),
      ),
      GoRoute(
        path: '/user/social/user/:userId',
        builder: (context, state) => UserPublicProfilePage(
          userId: state.pathParameters['userId']!,
        ),
      ),

      // ==================== PROFILE SUB-PAGES ====================
      GoRoute(
        path: '/user/profile/purchases',
        builder: (context, state) => const PurchaseHistoryPage(),
      ),
      GoRoute(
        path: '/user/profile/borrows',
        builder: (context, state) => const BorrowHistoryPage(),
      ),
      GoRoute(
        path: '/user/profile/wallet',
        builder: (context, state) => const WalletPage(),
      ),
    ],
  );
});
