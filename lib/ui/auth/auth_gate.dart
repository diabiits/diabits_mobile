import 'package:diabits_mobile/domain/auth/auth_event_broadcaster.dart';
import 'package:diabits_mobile/ui/auth/login_screen.dart';
import 'package:diabits_mobile/ui/shared/error_snack_listener.dart';
import 'package:diabits_mobile/ui/shared/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/auth/auth_state_manager.dart';

/// A widget that acts as an authentication gate for the application.
///
/// It listens to the [AuthStateManager] and rebuilds the UI based on the
/// current authentication state. This is the first widget that determines
/// what the user sees when they open the app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  /// Builds the widget tree based on the current authentication state.
  /// - [AuthState.none]: Shows a custom loading screen while the app is initializing.
  /// - [AuthState.unauthenticated]: Shows the login screen.
  /// - [AuthState.authenticated]: Shows the main manual input screen.
  @override
  Widget build(BuildContext context) {
    final authState = context.select((AuthStateManager as) => as.authState);

    switch (authState) {
      case .none:
        return const LoadingScreen();
      case .unauthenticated:
        return const LoginScreen();
      case .authenticated:
        return const Scaffold();
    }
  }
}
