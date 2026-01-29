import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/auth/token_events.dart';
import '../auth/dtos/auth_response.dart';
import '../auth/token_storage.dart';
import 'endpoints.dart';

/// Handles all HTTP requests and manages authentication (access + refresh tokens).
class ApiClient {
  final TokenStorage _tokens;
  final http.Client _httpClient;
  final String _baseUrl = dotenv.env['BASE_URL']!;

  ApiClient({required TokenStorage tokens, http.Client? httpClient})
    : _tokens = tokens,
      _httpClient = httpClient ?? http.Client();

  Future<http.Response> get(String path, {Map<String, String>? params}) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path, params);
      return _httpClient.get(uri, headers: headers);
    });
  }

  Future<http.Response> post(String path, Object? body) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path);
      return _httpClient.post(uri, headers: headers, body: jsonEncode(body));
    });
  }

  Future<http.Response> put(String path, Object? body) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path);
      return _httpClient.put(uri, headers: headers, body: jsonEncode(body));
    });
  }

  Future<http.Response> delete(String path) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path);
      return _httpClient.delete(uri, headers: headers);
    });
  }

  Future<http.Response> _performRequest(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } catch (_) {
      return _buildError(503, "Service unavailable");
    }

    if (response.statusCode == 401) {
      final refreshResult = await _refreshAccessToken();

      if (refreshResult.statusCode == 200) {
        // Retry — request() uses fresh access automatically
        try {
          response = await request();
        } catch (_) {
          return _buildError(503, "Service unavailable");
        }
      } else {
        tokenEvents.add(TokenEvent.unauthorized);
      }
    }

    if (response.statusCode >= 500) {
      tokenEvents.add(TokenEvent.serverUnavailable);
    }

    return response;
  }

  // ───────────────────────────
  // Token handling
  // ───────────────────────────

  /// Attempts to refresh the access token using the stored refresh token.
  Future<http.Response> _refreshAccessToken() async {
    final refreshToken = await _tokens.getRefreshToken();

    if (refreshToken == null) {
      return _buildError(401, "No refresh token available");
    }

    try {
      final response = await _httpClient.post(
        _buildUri(Endpoints.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final auth = AuthResponse.fromJson(json);

        await _tokens.saveAccessToken(auth.accessToken);
        await _tokens.saveRefreshToken(auth.refreshToken);
      }

      return response;
    } catch (_) {
      return _buildError(503, "Service unavailable");
    }
  }

  // ───────────────────────────
  // Helpers
  // ───────────────────────────

  /// Builds the full URL with optional query parameters.
  Uri _buildUri(String path, [Map<String, String>? params]) {
    final uri = Uri.parse('$_baseUrl$path');
    return params != null ? uri.replace(queryParameters: params) : uri;
  }

  /// Builds HTTP headers with content type and authorization if available.
  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await _tokens.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Creates a basic error response with a message body.
  http.Response _buildError(int statusCode, String message) {
    return http.Response(
      jsonEncode({'message': message}),
      statusCode,
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Call this when you’re done using the client.
  void dispose() {
    _httpClient.close();
  }
}
