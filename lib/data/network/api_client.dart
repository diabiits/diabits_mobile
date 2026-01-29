import 'dart:async';
import 'dart:convert';
import 'package:diabits_mobile/domain/auth/auth_events.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/auth/auth_events.dart';
import '../auth/dtos/auth_response.dart';
import '../auth/token_storage.dart';
import 'endpoints.dart';

//TODO  bool _ownsClient;?
/// A centralized HTTP client for making API requests.
///
/// This class wraps the [http] package to provide a unified interface for
/// all backend communication. It automatically handles adding the authorization
/// header and refreshing expired access tokens.
class ApiClient {
  final TokenStorage _tokens;
  final http.Client _httpClient;
  final String _baseUrl = dotenv.env['BASE_URL']!;

  /// Creates a new instance of [ApiClient].
  ///
  /// It requires a [TokenStorage] instance to manage authentication tokens.
  ApiClient({required TokenStorage tokens, http.Client? httpClient})
    : _tokens = tokens,
      _httpClient = httpClient ?? http.Client();

  /// Sends a POST request to the specified path with an optional body.
  Future<http.Response> post(String path, Object? body) async {
    return _sendRequest((headers) {
      final url = Uri.parse('$_baseUrl$path');
      return _httpClient.post(url, headers: headers, body: jsonEncode(body));
    });
  }

  /// Sends a PUT request to the specified path with an optional body.
  Future<http.Response> put(String path, Object? body) async {
    return _sendRequest((headers) {
      final url = Uri.parse('$_baseUrl$path');
      return _httpClient.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  /// Sends a GET request to the specified path with optional query parameters.
  Future<http.Response> get(String path, {Map<String, String>? params}) async {
    return _sendRequest((headers) {
      var url = Uri.parse('$_baseUrl$path');
      if (params != null) {
        url = url.replace(queryParameters: params);
      }
      return _httpClient.get(url, headers: headers);
    });
  }

  /// Sends a DELETE request to the specified path.
  Future<http.Response> delete(String path) async {
    return _sendRequest((headers) {
      final url = Uri.parse('$_baseUrl$path');
      return _httpClient.delete(url, headers: headers);
    }).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        return http.Response(
          jsonEncode({"message": "Couldn't reach server"}),
          503,
        );
      },
    );
  }

  /// Sends a request and automatically handles token refresh on 401 errors.
  ///
  /// This private method is the core of the [ApiClient]. It takes a function
  /// that creates the request, executes it, and if a 401 Unauthorized
  /// response is received, it attempts to refresh the token and retry the request.
  /// If the refresh fails, it broadcasts a global logout event.
  Future<http.Response> _sendRequest(
    Future<http.Response> Function(Map<String, String> headers) makeRequest,
  ) async {
    final headers = await _buildHeaders();
    var response = await makeRequest(headers);

    if (response.statusCode == 401) {
      final bool refreshed = await _refreshToken();
      if (refreshed) {
        // Rebuild headers with the new token and retry the request.
        final newHeaders = await _buildHeaders();
        response = await makeRequest(newHeaders);
      } else {
        // If refresh fails, broadcast a logout event.
        authEvents.add(AuthEvent.logout);
      }
    }
    return response;
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns `true` if the token was successfully refreshed, otherwise `false`.
  Future<bool> _refreshToken() async {
    final refreshToken = await _tokens.getRefreshToken();
    if (refreshToken == null) return false;

    final url = Uri.parse('$_baseUrl${Endpoints.refreshToken}');
    // This request uses the raw _httpClient to avoid a retry loop.
    final response = await _httpClient.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode != 200) {
      return false;
    }

    final authResponse = AuthResponse.fromJson(jsonDecode(response.body));
    await _tokens.saveAccessToken(authResponse.accessToken);
    await _tokens.saveRefreshToken(authResponse.refreshToken);
    return true;
  }

  /// Constructs the headers for an API request, including the auth token if available.
  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final accessToken = await _tokens.getAccessToken();
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }

  void dispose() => _httpClient.close();
}
