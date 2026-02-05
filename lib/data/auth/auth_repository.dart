import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:diabits_mobile/data/network/endpoints.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';

import 'dtos/auth_response.dart';
import 'dtos/auth_result.dart';
import 'dtos/login_request.dart';
import 'dtos/register_request.dart';
import 'token_storage.dart';

/// A repository for handling authentication-related operations.
///
/// This class communicates with the backend to perform user registration, login,
/// and logout. It also handles token storage and validation for automatic login.
class AuthRepository {
  final TokenStorage _tokens;
  final ApiClient _client;

  /// Creates a new instance of [AuthRepository].
  AuthRepository({required TokenStorage tokens, required ApiClient client})
    : _tokens = tokens,
      _client = client;

  /// Registers a new user with the backend.
  ///
  /// It sends the user's registration details and, upon success, saves the
  /// returned authentication tokens. Returns a tuple with the registration
  /// status and an optional error message.
  Future<AuthResult> register(RegisterRequest request) async {
    var result = await _client.post(Endpoints.register, request.toJson());

    if (result.success) {
      final authResponse = AuthResponse.fromJson(result.body);
      await _tokens.saveAccessToken(authResponse.accessToken);
      await _tokens.saveRefreshToken(authResponse.refreshToken);
      return AuthResult(true, null);
    }

    return AuthResult(false, result.message);
  }

  /// Logs in a user with the given credentials.
  ///
  /// It sends a login request to the backend and, if successful, stores the
  /// authentication tokens. Returns a tuple with the login status and an
  /// optional error message.
  Future<AuthResult> login(LoginRequest request) async {
    final result = await _client.post(Endpoints.login, request.toJson());

    if (result.success) {
      final authResponse = AuthResponse.fromJson(result.body);
      await _tokens.saveAccessToken(authResponse.accessToken);
      await _tokens.saveRefreshToken(authResponse.refreshToken);
      return AuthResult(true, null);
    }

    return AuthResult(false, result.message);
  }

  /// Logs out the current user.
  ///
  /// It sends a request to the backend to invalidate the refresh token and then
  /// clears all local tokens.
  Future<void> logout() async {
    final refreshToken = await _tokens.getRefreshToken();

    if (refreshToken != null) {
      await _client.post(Endpoints.logout, {"refreshToken": refreshToken});
    }

    await _tokens.clearAll();
  }

  /// Attempts to automatically log in the user by validating existing tokens.
  Future<AuthState> autoLogin() async {
    final response = await _client.get(Endpoints.checkToken);

    return response.success
        ? AuthState.authenticated
        : AuthState.unauthenticated;
  }

  /// Checks if both access and refresh tokens are stored locally.
  Future<bool> hasTokens() async {
    final accessToken = await _tokens.getAccessToken();
    final refreshToken = await _tokens.getRefreshToken();

    return accessToken != null && refreshToken != null;
  }
}
