import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter/cupertino.dart';

/// This class handles the business logic for the registration process, including
/// managing the loading state and password visibility.
/// It communicates with [AuthStateManager] to perform the actual registration.
///
/// For a user to be able to register they need to have a valid invite code
/// with the corresponding email.
/// Invites can only be created by admins and are stored in the backend.
class RegisterViewModel extends ChangeNotifier {
  final AuthStateManager _authManager;

  RegisterViewModel({required AuthStateManager authManager})
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

  Future<void> submit({
    required String username,
    required String password,
    required String email,
    required String inviteCode,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final message = await _authManager.register(
      username.trim(),
      password,
      email.trim(),
      inviteCode.trim(),
    );

    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}