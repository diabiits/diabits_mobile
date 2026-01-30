import 'dart:async';

//TODO Use more instead of bubbling http status all the way to ui?
//TODO Remove?
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

/// An enum representing the different types of authentication events.
enum AuthEvent { loginNeeded, serverUnavailable }

/// A global singleton instance of the [AuthEvents] class.
final authEvents = AuthEvents();
