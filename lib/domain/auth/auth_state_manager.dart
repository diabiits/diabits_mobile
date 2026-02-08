import 'dart:async';

import 'package:diabits_mobile/data/auth/dtos/login_request.dart';
import 'package:diabits_mobile/data/health_connect/sync_scheduler.dart';
import 'package:diabits_mobile/domain/auth/auth_event_broadcaster.dart';
import 'package:flutter/material.dart';

import 'package:diabits_mobile/data/auth/auth_repository.dart';

import '../../data/auth/dtos/register_request.dart';

/// Manages the authentication state of the application that decides navigation.
class AuthStateManager extends ChangeNotifier {
  final AuthRepository _authRepo;
  final SyncScheduler _syncScheduler;
  late final StreamSubscription<AuthEvent> _authEventSubscription;

  AuthStateManager({
    required AuthRepository authRepo,
    required SyncScheduler syncCoordinator,
  }) : _authRepo = authRepo,
       _syncScheduler = syncCoordinator {
    _authEventSubscription = authEvents.stream.listen((event) {
      if (event == AuthEvent.loginNeeded) {
        _handleLogout();
      }
    });
  }

  /// The current authentication state of the app. Defaults to [AuthState.none].
  AuthState _authState = .none;
  AuthState get authState => _authState;

  Future<String?> register(RegisterRequest request) async {
    final result = await _authRepo.register(request);

    if (result.success) {
      await _handleLoginSuccess();
    }
    return result.message;
  }

  Future<String?> login(LoginRequest request) async {
    final result = await _authRepo.login(request);

    if (result.success) {
      await _handleLoginSuccess();
    }
    return result.message;
  }

  Future<void> logout() async {
    await _authRepo.logout();
    await _handleLogout();
  }

  Future<void> _handleLoginSuccess() async {
    _authState = AuthState.authenticated;
    notifyListeners();
    await _syncScheduler.startBackgroundSync();
  }

  Future<void> _handleLogout() async {
    _authState = AuthState.unauthenticated;
    notifyListeners();
    await _syncScheduler.stopBackgroundSync();
  }

  /// Initializes the authentication state when the app starts.
  ///
  /// It first checks for the existence of local tokens to provide optimistic
  /// access, and then tries to validate them with the backend.
  /// It also starts the background sync if the user is authenticated.
  Future<void> tryAutoLogin() async {
    final hasTokens = await _authRepo.hasTokens();
    if (hasTokens) {
      _authState = AuthState.authenticated;
      notifyListeners();

      /// Try validating tokens with backend
      final validAuthState = await _authRepo.autoLogin();

      if (validAuthState == null) return;

      if (validAuthState == AuthState.authenticated) {
        await _syncScheduler.startBackgroundSync();
      } else {
        _authState = validAuthState;
      }
    } else {
      _authState = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}

/// An enum representing the different authentication states of the app.
enum AuthState { none, unauthenticated, authenticated }