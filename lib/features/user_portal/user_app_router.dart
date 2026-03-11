import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'presentation/auth/user_login_page.dart';
import 'presentation/auth/user_register_page.dart';
import 'presentation/shell/user_main_shell.dart';
import 'presentation/home/user_home_page.dart';
import 'presentation/book/user_book_detail_page.dart';
import 'presentation/book/buy_checkout_page.dart';
import 'presentation/book/borrow_checkout_page.dart';
import 'presentation/social/social_feed_page.dart';
import 'presentation/social/user_review_page.dart';
import 'presentation/social/user_public_profile_page.dart';
import 'presentation/qr/qr_scanner_page.dart';
import 'presentation/profile/user_profile_page.dart';
import 'presentation/profile/purchase_history_page.dart';
import 'presentation/profile/borrow_history_page.dart';
import 'presentation/profile/wallet_page.dart';

/// ==================== USER PORTAL ROUTES ====================
///
/// /user/login          -> Đăng nhập Member
/// /user/register       -> Đăng ký Member mới
/// /user/               -> Main Shell (Bottom Navigation)
///   ├── /user/home     -> Tab Trang chủ (Khám phá sách)
///   ├── /user/social   -> Tab Cộng đồng
///   ├── /user/scan     -> Tab Quét QR
///   └── /user/profile  -> Tab Cá nhân
///
/// /user/book/:id       -> Chi tiết sách
/// /user/book/:id/buy   -> Checkout Mua sách
/// /user/book/:id/borrow -> Checkout Mượn sách
/// /user/social/review/:id -> Viết/Xem review
/// /user/social/user/:id   -> Profile người dùng khác
/// /user/profile/purchases -> Lịch sử mua
/// /user/profile/borrows   -> Lịch sử mượn
/// /user/profile/wallet    -> Quản lý ví

/// Keys cho navigator
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration cho User Portal
final userAppRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/user/login',
  routes: [
    // ==================== AUTH ====================
    GoRoute(
      path: '/user/login',
      builder: (context, state) => const UserLoginPage(),
    ),
    GoRoute(
      path: '/user/register',
      builder: (context, state) => const UserRegisterPage(),
    ),

    // ==================== MAIN SHELL ====================
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
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
