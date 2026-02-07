import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

/// State for login page.
class LoginState {
  const LoginState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.isAuthenticated = false,
    this.userRole,
  });

  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool isAuthenticated;
  final UserRole? userRole;

  LoginState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? isAuthenticated,
    UserRole? userRole,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userRole: userRole ?? this.userRole,
    );
  }
}

/// ViewModel for handling login/signup logic.
class LoginViewModel extends Notifier<LoginState> {
  late AuthRepository _authRepo;

  @override
  LoginState build() {
    _authRepo = ref.watch(authRepositoryProvider);
    return const LoginState();
  }

  /// Clear all messages.
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  /// Login with email and password.
  ///
  /// Returns [AuthResult] on success, null on failure.
  Future<AuthResult?> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _authRepo.login(email: email, password: password);

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userRole: result.role,
        successMessage: result.message,
      );
      return result;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
      return null;
    }
  }

  /// Sign up with email and password.
  ///
  /// Returns [AuthResult] on success, null on failure.
  Future<AuthResult?> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _authRepo.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );

    if (result.success) {
      state = state.copyWith(
        isLoading: false,
        successMessage: result.message,
      );
      return result;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.message,
      );
      return null;
    }
  }

  /// Logout current user.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final result = await _authRepo.logout();

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      userRole: null,
      successMessage: result.success ? result.message : null,
      errorMessage: result.success ? null : result.message,
    );
  }
}

/// Provider for LoginViewModel.
final loginViewModelProvider =
    NotifierProvider<LoginViewModel, LoginState>(LoginViewModel.new);

