import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/auth/auth_event_broadcaster.dart';

//TODO Remove?
class ErrorSnackListener extends StatefulWidget {
  final Widget child;

  const ErrorSnackListener({required this.child, super.key});

  @override
  State<ErrorSnackListener> createState() => _ErrorSnackListenerState();
}

class _ErrorSnackListenerState extends State<ErrorSnackListener> {
  late final StreamSubscription<AuthEvent> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = authEvents.stream.listen((event) {
      switch (event) {
        case AuthEvent.loginNeeded:
          _showSnackbar("Login expired. Please log in again.");
          break;
        case AuthEvent.serverUnavailable:
          _showSnackbar("Server unavailable. Try again later.");
          break;
      }
    });
  }

  void _showSnackbar(String message) {
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
  //
  // const ErrorSnackListener({
  //   super.key,
  //   required this.child,
  //   required this.errorMessage,
  //   required this.onClear,
  // });
  //
  // final Widget child;
  // final String? errorMessage;
  // final VoidCallback onClear;
  //
  // @override
  // Widget build(BuildContext context) {
  //   final message = errorMessage;
  //   if (message != null) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (!context.mounted) return;
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(message),
  //           backgroundColor: Colors.red,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //
  //       onClear();
  //     });
  //   }
  //   return child;
  // }
}
