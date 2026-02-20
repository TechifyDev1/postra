import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:postra/src/features/auth/data/models/login_request.dart';
import 'package:postra/src/features/auth/data/models/register_request.dart';
import 'package:postra/src/features/auth/domain/entities/user_entity.dart';
import 'package:postra/src/features/auth/domain/usercases/get_current_user_usecase.dart';
import 'package:postra/src/features/auth/domain/usercases/login_usecase.dart';
import 'package:postra/src/features/auth/domain/usercases/logout_usecase.dart';
import 'package:postra/src/features/auth/domain/usercases/register_usecase.dart';
import 'package:postra/src/core/network/auth_event_provider.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUsecase loginUsecase;
  final RegisterUsecase registerUsecase;
  final LogoutUsecase logoutUsecase;
  final GetCurrentUserUsecase getCurrentUserUsecase;

  AuthProvider(
    this.loginUsecase,
    this.registerUsecase,
    this.logoutUsecase,
    this.getCurrentUserUsecase,
  ) {
    getCurrentUser();
  }

  UserEntity? _currentUser;
  bool _isLoading = false;
  bool _isLoggingIn = false;
  bool _isRegistering = false;

  String? _loginError;
  String? _registerError;
  String? _currentUserError;

  UserEntity? get currentUser => _currentUser;

  Future<void> handleUnauthorized() async {
    // If we get a 401, it means the token is invalid or expired.
    // We should clear the local state and storage.
    await logout();
    _currentUser = null;
    _currentUserError = 'Session expired. Please login again.';
    notifyListeners();
  }

  bool get isGuest => _currentUser == null;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isLoggingIn => _isLoggingIn;
  bool get isRegistering => _isRegistering;

  String? get loginError => _loginError;
  String? get registerError => _registerError;
  String? get currentUserError => _currentUserError;

  Future<void> login(LoginRequest request) async {
    _loginError = null;
    try {
      _isLoggingIn = true;
      notifyListeners();
      _currentUser = await loginUsecase(request);
    } catch (e) {
      _loginError = e.toString();
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  Future<void> register(RegisterRequest request) async {
    _registerError = null;
    try {
      _isRegistering = true;
      notifyListeners();
      _currentUser = await registerUsecase(request);
    } catch (e) {
      _registerError = e.toString();
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      await logoutUsecase();
      _currentUser = null;
    } catch (e) {
      // Handle logout error if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCurrentUser() async {
    _currentUserError = null;
    try {
      _isLoading = true;
      notifyListeners();
      _currentUser = await getCurrentUserUsecase();
    } catch (e) {
      _currentUserError = e.toString();
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  final notifier = AuthProvider(
    ref.read(loginUsecaseProvider),
    ref.read(registerUsecaseProvider),
    ref.read(logoutUsecaseProvider),
    ref.read(getCurrentUserUsecaseProvider),
  );

  // Listen for 401 events from HttpClient without creating a circular dependency
  ref.listen(unauthorizedEventProvider, (previous, next) {
    if (next > 0) {
      notifier.handleUnauthorized();
    }
  });

  return notifier;
});
