import 'dart:async';

/// Simple event bus for broadcasting authentication-related events.
/// This allows different parts of the app to communicate about global transient events.
class AuthEvents {
  final _streamController = StreamController<AuthEvent>.broadcast();

  /// The stream of authentication events.
  Stream<AuthEvent> get stream => _streamController.stream;

  /// Adds a new authentication event to the stream.
  void add(AuthEvent event) => _streamController.add(event);

  void dispose() => _streamController.close();
}

enum AuthEvent {
  loginNeeded("Your session expired. Please log in again."),
  serverUnavailable("Server is currently unavailable.");

  final String message;
  const AuthEvent(this.message);
}
/// A global singleton instance of the [AuthEvents] class.
final authEvents = AuthEvents();
