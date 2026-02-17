//TODO Remove refreshToken?
class AuthResponse {
  /// The JWT access token used for authenticating subsequent API requests.
  final String accessToken;
  final String refreshToken;

  /// Creates a new instance of [AuthResponse].
  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  /// Creates an [AuthResponse] instance from a JSON map.
  ///
  /// This factory is used to deserialize the response body from the backend.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
