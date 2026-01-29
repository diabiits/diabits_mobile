import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter/cupertino.dart';

/// This class handles the business logic for the login process, including
/// managing the loading state and password visibility.
/// It communicates with the [AuthStateManager] to perform the actual login.
class LoginViewModel extends ChangeNotifier {
  final AuthStateManager _authManager;

  /// Creates a new instance of [LoginViewModel].
  LoginViewModel({required AuthStateManager authManager})
      : _authManager = authManager;

  bool _isLoading = false;
  String? _errorMessage;
  bool _passwordHidden = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get passwordHidden => _passwordHidden;

  void togglePasswordVisibility() {
    _passwordHidden = !_passwordHidden;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Logs in the user with the given username and password.
  /// It sets the loading state, calls the [AuthStateManager] to perform the
  /// login, and returns an error message if the login fails.
  Future<void> submit({
    required String username,
    required String password,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final message = await _authManager.login(username.trim(), password);

    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}