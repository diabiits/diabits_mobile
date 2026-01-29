import 'package:flutter/material.dart';

import 'ui/auth/auth_gate.dart';

/// The root widget of the Diabits application.
///
/// This widget sets up the [MaterialApp], including the app's title, theme,
/// and the initial route, which is the [AuthGate].
class DiabitsApp extends StatelessWidget {
  const DiabitsApp({super.key});

  /// Builds the UI for the application.
  ///
  /// It configures the [MaterialApp] with a custom theme and sets the
  /// [AuthGate] as the home widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabits',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFef88ad),
          brightness: Brightness.light,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
