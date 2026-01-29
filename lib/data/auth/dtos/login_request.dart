/// Represents the data transfer object (DTO) for a login request.
///
/// This class is used to structure the user's credentials before sending them
/// to the backend for authentication.
class LoginRequest {
  final String username;
  final String password;

  /// Creates a new instance of [LoginRequest].
  LoginRequest({required this.username, required this.password});

  /// Converts the [LoginRequest] instance to a JSON map.
  ///
  /// This method is used to serialize the object before sending it as the
  /// request body.
  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}
