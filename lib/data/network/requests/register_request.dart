/// Represents the data transfer object (DTO) for a registration request.
///
/// This class is used to structure the new user's details before sending them
/// to the backend for account creation.
class RegisterRequest {
  final String username;
  final String password;
  final String email;
  final String inviteCode;

  /// Creates a new instance of [RegisterRequest].
  RegisterRequest({
    required this.username,
    required this.password,
    required this.email,
    required this.inviteCode,
  });

  /// Converts the [RegisterRequest] instance to a JSON map.
  ///
  /// This method is used to serialize the object before sending it as the
  /// request body.
  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'email': email,
    'inviteCode': inviteCode,
  };
}
