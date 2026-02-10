import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/auth/auth_event_broadcaster.dart';

/// A widget that listens for global authentication events and provides UI feedback.
///
/// This listener monitors the [authEvents] stream for critical session changes, such as expired
/// credentials or server connectivity issues, and notifies the user via [SnackBar] notifications.
class AuthEventListener extends StatefulWidget {
  final Widget child;
  const AuthEventListener({required this.child, super.key});

  @override
  State<AuthEventListener> createState() => _AuthEventListenerState();
}

/// Manages the stream subscription and UI side-effects for authentication events.
class _AuthEventListenerState extends State<AuthEventListener> {
  late final StreamSubscription<AuthEvent> _subscription;

  @override
  void initState() {
    super.initState();

    // Establishes a permanent listener for broadcasted AuthEvents.
    _subscription = authEvents.stream.listen((event) {
      _showMessage(event.message);
    });
  }

  /// Displays a [SnackBar] message to the user.
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
