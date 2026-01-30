import 'package:diabits_mobile/data/auth/auth_repository.dart';
import 'package:diabits_mobile/data/auth/dtos/login_request.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter/cupertino.dart';

/// This class handles the business logic for the login process, including
/// managing the loading state and password visibility.
/// It communicates with the [AuthStateManager] to perform the actual login.
class LoginViewModel extends ChangeNotifier {
  final AuthStateManager _authManager;
  final AuthRepository _authRepo;

  /// Creates a new instance of [LoginViewModel].
  LoginViewModel({
    required AuthStateManager authManager,
    required AuthRepository authRepo,
  }) : _authManager = authManager,
       _authRepo = authRepo;

  bool _isLoading = false;
  bool _passwordHidden = true;
  String? _snackMessage;

  bool get isLoading => _isLoading;
  bool get passwordHidden => _passwordHidden;
  String? get snackMessage => _snackMessage;

  void togglePasswordVisibility() {
    _passwordHidden = !_passwordHidden;
    notifyListeners();
  }

  void clearSnack() {
    _snackMessage = null;
  }

  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final (success, message) = await _authRepo.login(
      LoginRequest(username: username.trim(), password: password),
    );

    _isLoading = false;
    if (success) {
      await _authManager.markAuthenticated();
    }
    else if (message != null) {
      _snackMessage = message;
    }
    notifyListeners();
  }
}