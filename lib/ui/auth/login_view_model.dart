import 'package:diabits_mobile/data/auth/auth_repository.dart';
import 'package:diabits_mobile/data/network/requests/login_request.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter/cupertino.dart';

/// Manages the state and business logic for the login screen.
///
/// This view model handles user credentials submission, UI loading states,
/// and password visibility toggling. It coordinates between [AuthRepository]
/// for network requests and [AuthStateManager] for global session state.
class LoginViewModel extends ChangeNotifier {
  final AuthStateManager _authManager;

  LoginViewModel({required AuthStateManager authManager}) : _authManager = authManager;

  bool _isLoading = false;
  bool _passwordHidden = true;
  String? _snackMessage;

  bool get isLoading => _isLoading;
  bool get passwordHidden => _passwordHidden;
  String? get snackMessage => _snackMessage;

  /// Switches the visibility state of the password input field.
  void togglePasswordVisibility() {
    _passwordHidden = !_passwordHidden;
    notifyListeners();
  }

  /// Clears the current message to prevent duplicate notifications.
  void clearSnack() {
    _snackMessage = null;
  }

  /// Attempts to authenticate the user with the provided [username] and [password].
  ///
  /// Updates [isLoading] during the request and triggers [AuthStateManager.markAuthenticated] upon success.
  /// If the request fails, updates [snackMessage] with the error details.
  Future<void> submit({required String username, required String password}) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final message = await _authManager.login(
      LoginRequest(username: username.trim(), password: password),
    );

    _isLoading = false;
    if (message?.isNotEmpty == true) _snackMessage = message;
    notifyListeners();
  }
}
