import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/auth/auth_event_broadcaster.dart';

class AuthEventListener extends StatefulWidget {
  final Widget child;

  const AuthEventListener({required this.child, super.key});

  @override
  State<AuthEventListener> createState() => _AuthEventListenerState();
}

class _AuthEventListenerState extends State<AuthEventListener> {
  late final StreamSubscription<AuthEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = authEvents.stream.listen((event) {
      switch (event) {
        case AuthEvent.loginNeeded:
          _showMessage("Your session expired. Please log in again.");
          break;
        case AuthEvent.serverUnavailable:
          _showMessage("Server is currently unavailable.");
          break;
      }
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final context = this.context;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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