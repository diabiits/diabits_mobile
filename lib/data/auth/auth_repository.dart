import 'dart:convert';

import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:diabits_mobile/data/network/endpoints.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:http/http.dart' as http;

import 'dtos/auth_response.dart';
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
  ///
  /// It requires a [TokenStorage] instance to manage authentication tokens and
  /// an [ApiClient] to make network requests.
  AuthRepository({required TokenStorage tokens, required ApiClient client})
      : _tokens = tokens,
        _client = client;

  /// Registers a new user with the backend.
  ///
  /// It sends the user's registration details and, upon success, saves the
  /// returned authentication tokens. Returns a tuple with the registration
  /// status and an optional error message.
  Future<(bool status, String? message)> register(
      RegisterRequest request,
      ) async {
    var response = await _client.post(Endpoints.register, request.toJson());

    if (response.statusCode == 503 || response.statusCode == 400) {
      var body = jsonDecode(response.body);
      return (false, body["message"].toString());
    }
    if (response.statusCode != 201) {
      return (false, "Unknown error");
    }

    final json = jsonDecode(response.body);
    final authResponse = AuthResponse.fromJson(json);

    await _tokens.saveAccessToken(authResponse.accessToken);
    await _tokens.saveRefreshToken(authResponse.refreshToken);

    return (true, null);
  }

  /// Logs in a user with the given credentials.
  ///
  /// It sends a login request to the backend and, if successful, stores the
  /// authentication tokens. Returns a tuple with the login status and an
  /// optional error message.
  Future<(bool success, String? message)> login(LoginRequest request) async {
    final response = await _client
        .post(Endpoints.login, request.toJson())
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () =>
          http.Response("Server unavailable. Try again later.", 503),
    );

    if (response.statusCode == 400) {
      var body = jsonDecode(response.body);
      return (false, body["message"].toString());
    } else if (response.statusCode == 503) {
      return (false, response.body.toString());
    }
    if (response.statusCode != 200) {
      return (false, "Unknown error");
    }

    final json = jsonDecode(response.body);
    final authResponse = AuthResponse.fromJson(json);

    await _tokens.saveAccessToken(authResponse.accessToken);
    await _tokens.saveRefreshToken(authResponse.refreshToken);
    return (true, null);
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
  ///
  /// It sends a request to a protected endpoint to check if the current access
  /// token is valid. Returns the appropriate [AuthState] based on the response.
  Future<AuthState> tryAutoLogin() async {
    final response = await _client.get(Endpoints.checkToken);

    if (response.statusCode == 200) {
      return AuthState.authenticated;
    } else {
      return AuthState.loginRequired;
    }
  }

  /// Checks if both access and refresh tokens are stored locally.
  Future<bool> hasTokens() async {
    final accessToken = await _tokens.getAccessToken();
    final refreshToken = await _tokens.getRefreshToken();

    return accessToken != null && refreshToken != null;
  }
}
