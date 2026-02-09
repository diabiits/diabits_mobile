/// Represents the authentication response from the backend.
///
/// This DTO is used to parse the JSON response from the login and register
/// endpoints, providing the access token, its expiration date, and the
/// refresh token.
class AuthResponse {
  /// The JWT access token used for authenticating subsequent API requests.
  final String accessToken;

  /// The expiration date and time of the access token.
  final DateTime expiresAt;

  /// The refresh token used to obtain a new access token when the current one
  /// expires.
  final String refreshToken;

  /// Creates a new instance of [AuthResponse].
  AuthResponse({
    required this.accessToken,
    required this.expiresAt,
    required this.refreshToken,
  });

  /// Creates an [AuthResponse] instance from a JSON map.
  ///
  /// This factory is used to deserialize the response body from the backend.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
      refreshToken: json['refreshToken'],
    );
  }
}
