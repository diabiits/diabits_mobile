import 'dart:async';

//TODO Use more instead of bubbling http status all the way to ui?
/// A simple event bus for broadcasting and listening to authentication-related events.
///
/// This allows different parts of the app to communicate about authentication state
/// changes without being directly coupled.
class AuthEvents {
  final _streamController = StreamController<AuthEvent>.broadcast();

  /// The stream of authentication events.
  Stream<AuthEvent> get stream => _streamController.stream;

  /// Adds a new authentication event to the stream.
  void add(AuthEvent event) {
    _streamController.add(event);
  }

  /// Closes the stream controller. Should be called when the app is disposed.
  void dispose() {
    _streamController.close();
  }
}

/// An enum representing the different types of authentication events.
enum AuthEvent {
  /// An event that signals that the user should be logged out.
  logout,
}

/// A global singleton instance of the [AuthEvents] class.
final authEvents = AuthEvents();
