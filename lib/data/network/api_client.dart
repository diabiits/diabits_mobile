import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../domain/auth/auth_event_broadcaster.dart';
import 'responses/auth_response.dart';
import '../auth/token_storage.dart';
import 'dtos/api_result.dart';
import 'endpoints.dart';

/// Handles all HTTP requests and manages authentication (access + refresh tokens).
class ApiClient {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  final String _baseUrl = dotenv.env['BASE_URL']!;

  final TokenStorage _tokens;
  final http.Client _httpClient;

  ApiClient({required TokenStorage tokens, http.Client? httpClient})
    : _tokens = tokens,
      _httpClient = httpClient ?? http.Client();

  Future<ApiResult> get(String path, {Map<String, String>? params}) {
    return _performRequest(
      () async => _httpClient.get(_buildUri(path, params), headers: await _buildHeaders()),
    );
  }

  Future<ApiResult> post(String path, Object? body, {Duration? timeout}) {
    return _performRequest(
      () async =>
          _httpClient.post(_buildUri(path), headers: await _buildHeaders(), body: jsonEncode(body)),
      timeout: timeout ?? _defaultTimeout,
    );
  }

  Future<ApiResult> put(String path, Object? body) {
    return _performRequest(
      () async =>
          _httpClient.put(_buildUri(path), headers: await _buildHeaders(), body: jsonEncode(body)),
    );
  }

  Future<ApiResult> delete(String path, {Object? body}) {
    return _performRequest(
      () async => _httpClient.delete(
        _buildUri(path),
        headers: await _buildHeaders(),
        body: jsonEncode(body),
      ),
    );
  }

  Future<ApiResult> _performRequest(
    Future<http.Response> Function() request, {
    Duration timeout = _defaultTimeout,
  }) async {
    http.Response response;

    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      authEvents.add(AuthEvent.serverUnavailable);
      return ApiResult(success: false, statusCode: 503, message: "Server unavailable");
    }

    if (response.statusCode == 401) {
      final refreshStatus = await _refreshAccessToken();

      if (refreshStatus == 200) {
        response = await request();
      } else {
        authEvents.add(refreshStatus == 401 ? AuthEvent.loginNeeded : AuthEvent.serverUnavailable);
        return ApiResult(
          success: false,
          statusCode: refreshStatus,
          message: refreshStatus == 401 ? "Session expired" : "Server unavailable",
        );
      }
    }

    final decodedBody = _tryDecodeJson(response.body);

    if (response.statusCode >= 400) {
      debugPrint('API Error [${response.statusCode}] on ${response.request?.url}');
      debugPrint('Response body: ${response.body}');
    }

    return ApiResult(
      success: response.statusCode >= 200 && response.statusCode < 300,
      body: decodedBody,
      statusCode: response.statusCode,
      message: decodedBody is Map ? decodedBody["message"]?.toString() : null,
    );
  }

  /// Attempts to refresh the access token using the stored refresh token.
  Future<int> _refreshAccessToken() async {
    final refreshToken = await _tokens.getRefreshToken();

    if (refreshToken == null) return 401;

    try {
      final response = await _httpClient
          .post(
            _buildUri(Endpoints.refreshToken),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_defaultTimeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final auth = AuthResponse.fromJson(json);

        await _tokens.saveAccessToken(auth.accessToken);
        await _tokens.saveRefreshToken(auth.refreshToken);
      }

      return response.statusCode;
    } on TimeoutException {
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

  dynamic _tryDecodeJson(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
