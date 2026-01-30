import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/auth/auth_event_broadcaster.dart';
import '../auth/dtos/auth_response.dart';
import '../auth/token_storage.dart';
import 'dtos/api_result.dart';
import 'endpoints.dart';

/// Handles all HTTP requests and manages authentication (access + refresh tokens).
class ApiClient {
  final TokenStorage _tokens;
  final http.Client _httpClient;
  final String _baseUrl = dotenv.env['BASE_URL']!;

  ApiClient({required TokenStorage tokens, http.Client? httpClient})
    : _tokens = tokens,
      _httpClient = httpClient ?? http.Client();

  Future<ApiResult> get(String path, {Map<String, String>? params}) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path, params);
      return _httpClient.get(uri, headers: headers);
    });
  }

  Future<ApiResult> post(String path, Object? body) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path);
      return _httpClient.post(uri, headers: headers, body: jsonEncode(body));
    });
  }

  Future<ApiResult> put(String path, Object? body) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path);
      return _httpClient.put(uri, headers: headers, body: jsonEncode(body));
    });
  }

  Future<ApiResult> delete(String path) {
    return _performRequest(() async {
      final headers = await _buildHeaders();
      final uri = _buildUri(path);
      return _httpClient.delete(uri, headers: headers);
    });
  }

  Future<ApiResult> _performRequest(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } on SocketException catch (_) {
      authEvents.add(AuthEvent.serverUnavailable);
      return ApiResult(success: false, message: "Server unavailable");
    }

    if (response.statusCode == 401) {
      final refreshStatus = await _refreshAccessToken();

      if (refreshStatus == 200) {
        try {
          response = await request().timeout(const Duration(seconds: 15));
        } on TimeoutException catch (_) {
          authEvents.add(AuthEvent.serverUnavailable);
          return ApiResult(success: false, message: "Server unavailable");
        }
      } else {
        authEvents.add(AuthEvent.loginNeeded);
        return ApiResult(
          success: false,
          message: "Tokens expired, please log in again",
          response: response,
        );
      }
    } else if (response.statusCode == 400) {
      return ApiResult(
        success: false,
        message: "Bad request", //TODO Refactor
        response: response,
      );
    }

    return ApiResult(success: true, response: response);
  }

  //TODO Refactor
  /// Attempts to refresh the access token using the stored refresh token.
  Future<int> _refreshAccessToken() async {
    final refreshToken = await _tokens.getRefreshToken();

    if (refreshToken == null) return 401;

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

      return 200;
    } catch (_) {
      return 503;
    }
  }

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

  void dispose() {
    _httpClient.close();
  }
}
