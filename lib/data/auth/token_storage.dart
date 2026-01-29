import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A secure storage for handling authentication tokens.
///
/// This class provides an abstraction layer over [FlutterSecureStorage] to
/// securely store, retrieve, and delete access and refresh tokens. The tokens
/// are encrypted on the device using platform-specific security features.
class TokenStorage {
  /// The key for storing the access token.
  static const _accessTokenKey = 'access_token';

  /// The key for storing the refresh token.
  static const _refreshTokenKey = 'refresh_token';

  /// An instance of [FlutterSecureStorage] configured for encrypted shared
  /// preferences on Android.
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Saves the access token to secure storage.
  /// This token is used to authenticate API calls.
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  /// Retrieves the access token from secure storage.
  /// Returns the stored access token, or `null` if it doesn't exist.
  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  /// Saves the refresh token to secure storage.
  /// This token is used to obtain a new access token when the current one expires.
  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _refreshTokenKey, value: token);

  /// Retrieves the refresh token from secure storage.
  /// Returns the stored refresh token, or `null` if it doesn't exist.
  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  /// Deletes all stored tokens from secure storage.
  /// This is called during logout or when tokens are invalidated.
  Future<void> clearAll() async => await _storage.deleteAll();
}