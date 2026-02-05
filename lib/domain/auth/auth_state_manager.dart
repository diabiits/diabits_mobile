import 'dart:async';

import 'package:diabits_mobile/data/health_connect/sync_scheduler.dart';
import 'package:diabits_mobile/domain/auth/auth_event_broadcaster.dart';
import 'package:flutter/material.dart';

import 'package:diabits_mobile/data/auth/auth_repository.dart';

/// Manages the authentication state of the application.
///
/// This class is responsible for handling user authentication, including login,
/// registration, logout, and automatic login attempts.
/// It interacts with the [AuthRepository] to communicate with the backend
/// and updates the UI by notifying its listeners of any state changes.
class AuthStateManager extends ChangeNotifier {
  final AuthRepository _authRepo;
  final SyncScheduler _syncScheduler;
  late final StreamSubscription<AuthEvent> _authEventSubscription;

  /// Creates a new instance of [AuthStateManager].
  /// Persistent authentication state that decides navigation.
  AuthStateManager({
    required AuthRepository authRepo,
    required SyncScheduler syncCoordinator,
  }) : _authRepo = authRepo,
       _syncScheduler = syncCoordinator {
    _authEventSubscription = authEvents.stream.listen((event) {
      if (event == AuthEvent.loginNeeded) {
        markUnauthenticated();
      }
    });
  }

  /// The current authentication state of the app. Defaults to [AuthState.none].
  AuthState _authState = .none;
  AuthState get authState => _authState;

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


  Future<void> markAuthenticated() async {
    _authState = AuthState.authenticated;
    notifyListeners();
    await _syncScheduler.startBackgroundSync();
  }

  Future<void> markUnauthenticated() async {
    _authState = AuthState.unauthenticated;
    notifyListeners();
    await _syncScheduler.stopBackgroundSync();
  }

  /// Logs out the current user.
  ///
  /// It clears the local tokens, stops the background sync, and updates the
  /// auth state to require login.
  // Future<void> logout() async {
  //   await _authRepo.logout();
  //   _authState = AuthState.unauthenticated;
  //   await _syncScheduler.stopBackgroundSync();
  //   notifyListeners();
  // }

  @override
  void dispose() {
    _authEventSubscription.cancel();
    super.dispose();
  }
}

/// An enum representing the different authentication states of the app.
enum AuthState { none, unauthenticated, authenticated }
