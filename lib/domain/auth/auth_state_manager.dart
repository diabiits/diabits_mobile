import 'dart:async';

import 'package:diabits_mobile/data/health_connect/sync_scheduler.dart';
import 'package:diabits_mobile/domain/auth/token_events.dart';
import 'package:flutter/material.dart';

import 'package:diabits_mobile/data/auth/auth_repository.dart';
import 'package:diabits_mobile/data/auth/dtos/login_request.dart';
import 'package:diabits_mobile/data/auth/dtos/register_request.dart';

/// Manages the authentication state of the application.
///
/// This class is responsible for handling user authentication, including login,
/// registration, logout, and automatic login attempts.
/// It interacts with the [AuthRepository] to communicate with the backend
/// and updates the UI by notifying its listeners of any state changes.
class AuthStateManager extends ChangeNotifier {
  final AuthRepository _authRepo;
  final SyncScheduler _syncScheduler;
  late final StreamSubscription<TokenEvent> _tokenEventSubscription;

  /// Creates a new instance of [AuthStateManager].
  ///
  /// It requires an [AuthRepository] for backend communication and a [SyncScheduler]
  /// to start synchronizations of Health Connect data when the user is authenticated.
  AuthStateManager({
    required AuthRepository authRepo,
    required SyncScheduler syncCoordinator,
  }) : _authRepo = authRepo,
       _syncScheduler = syncCoordinator {
    _tokenEventSubscription = tokenEvents.stream.listen((event) {
      if (event == TokenEvent.unauthorized) {
        logout();
        //TODO Add snackbar with explanation as to why user was logged out
      }
    });
  }

  /// The current authentication state of the app. Defaults to [AuthState.none].
  AuthState _authState = AuthState.none;
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
      final validAuthState = await _authRepo.tryAutoLogin();

      if (validAuthState == AuthState.authenticated) {
        await _syncScheduler.startBackgroundSync();
      } else {
        _authState = validAuthState;
      }
    } else {
      _authState = AuthState.loginRequired;
    }

    notifyListeners();
  }

  /// Registers a new user.
  ///
  /// It takes the user's credentials, sends them to the repository, and if
  /// successful, it updates the auth state and starts the background sync.
  /// Returns an error message if registration fails.
  Future<String?> register(
    String username,
    String password,
    String email,
    String inviteCode,
  ) async {
    final request = RegisterRequest(
      username: username,
      password: password,
      email: email,
      inviteCode: inviteCode,
    );

    final (success, message) = await _authRepo.register(request);

    if (!success) return message;

    _authState = AuthState.authenticated;
    notifyListeners();

    await _syncScheduler.startBackgroundSync();

    return null;
  }

  /// Logs in a user.
  ///
  /// It takes the user's credentials, sends them to the repository, and if
  /// successful, it updates the auth state and starts the background sync.
  /// Returns an error message if login fails.
  Future<String?> login(String username, String password) async {
    final request = LoginRequest(username: username, password: password);

    final (success, message) = await _authRepo.login(request);

    if (!success) return message;

    _authState = AuthState.authenticated;
    notifyListeners();
    await _syncScheduler.startBackgroundSync();

    return null;
  }

  /// Logs out the current user.
  ///
  /// It clears the local tokens, stops the background sync, and updates the
  /// auth state to require login.
  Future<void> logout() async {
    await _authRepo.logout();
    _authState = AuthState.loginRequired;
    await _syncScheduler.stopBackgroundSync();
    notifyListeners();
  }
}

/// An enum representing the different authentication states of the app.
enum AuthState { none, loginRequired, authenticated }
