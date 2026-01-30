import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter/cupertino.dart';

import '../../data/auth/auth_repository.dart';
import '../../data/auth/dtos/register_request.dart';

/// This class handles the business logic for the registration process, including
/// managing the loading state and password visibility.
/// It communicates with [AuthStateManager] to perform the actual registration.
///
/// For a user to be able to register they need to have a valid invite code
/// with the corresponding email.
/// Invites can only be created by admins and are stored in the backend.
class RegisterViewModel extends ChangeNotifier {
  final AuthStateManager _authManager;
  final AuthRepository _authRepo;

  RegisterViewModel({
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
    required String email,
    required String inviteCode,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final (success, message) = await _authRepo.register(
      RegisterRequest(
        username: username.trim(),
        password: password,
        email: email.trim(),
        inviteCode: inviteCode.trim(),
      ),
    );

    _isLoading = false;
    if (success) {
      await _authManager.markAuthenticated();
    } else if (message != null) {
      _snackMessage = message;
    }
    notifyListeners();
  }
}
