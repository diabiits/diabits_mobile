import 'package:flutter/material.dart';

class ErrorSnackListener extends StatelessWidget {
  const ErrorSnackListener({
    super.key,
    required this.child,
    required this.errorMessage,
    required this.onClear,
  });

  final Widget child;
  final String? errorMessage;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final message = errorMessage;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        onClear();
      });
    }
    return child;
  }
}
