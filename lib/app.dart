import 'package:diabits_mobile/ui/auth/auth_event_listener.dart';
import 'package:flutter/material.dart';

import 'auth_gate.dart';

/// The root widget of the Diabits application.
///
/// Responsible for configuring the global application theme, defining the core color palette,
/// and setting up the top-level navigation structure and authentication wrappers.
class DiabitsApp extends StatelessWidget {
  const DiabitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFAC0000);
    const secondaryColor = Color(0xFFEF88AD);
    const ternaryColor = Color(0xFF700507);
    const charcoal = Color(0xFF333333);

    return MaterialApp(
      title: 'Diabits',
      theme: ThemeData(
        useMaterial3: true,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: secondaryColor,
          selectionHandleColor: secondaryColor,
          selectionColor: Color(0x4DEF88AD),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          outline: Colors.grey[400],
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          labelStyle: const TextStyle(color: charcoal),
          floatingLabelStyle: const TextStyle(color: charcoal),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: charcoal, width: 1.5),
          ),

        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size.fromHeight(50),
          ),
        ),
        snackBarTheme: SnackBarThemeData(backgroundColor: ternaryColor),
      ),
      // Wraps the entire navigator to handle global authentication events.
      builder: (context, child) => AuthEventListener(child: child!),
      // Determines the initial screen based on authentication state.
      home: const AuthGate(),
    );
  }
}
