import 'package:diabits_mobile/app.dart';
import 'package:diabits_mobile/ui/auth/login_view_model.dart';
import 'package:diabits_mobile/ui/auth/register_view_model.dart';
import 'package:diabits_mobile/ui/manual_input/manual_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'data/auth/auth_repository.dart';
import 'data/auth/token_storage.dart';
import 'data/health_connect/health_connect_sync.dart';
import 'data/health_connect/permission_handler.dart';
import 'data/health_connect/sync_scheduler.dart';
import 'data/manual_input/manual_input_repository.dart';
import 'data/network/api_client.dart';
import 'domain/auth/auth_state_manager.dart';

/// Entry point of the Diabits application.
///
/// This function initializes essential system bindings, loads environment configurations,
/// and sets up the global dependency injection tree using [MultiProvider].
void main() async {
  // Ensure Flutter framework is ready before asynchronous initialization.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for API configuration and secrets.
  await dotenv.load();

  runApp(
    MultiProvider(
      providers: [
        // Provides a singleton instance of TokenStorage for secure token handling.
        Provider<TokenStorage>(create: (_) => TokenStorage()),

        // Provides the ApiClient, making it dependent on TokenStorage.
        Provider<ApiClient>(
          create: (context) => ApiClient(tokens: context.read<TokenStorage>()),
          dispose: (_, client) => client.dispose(),
        ),

        // Provides the AuthRepository, which depends on TokenStorage and ApiClient.
        Provider<AuthRepository>(
          create: (context) => AuthRepository(
            tokens: context.read<TokenStorage>(),
            client: context.read<ApiClient>(),
          ),
        ),

        // Provides the ManualInputRepository for handling manual data entries.
        Provider<ManualInputRepository>(
          create: (context) =>
              ManualInputRepository(client: context.read<ApiClient>()),
        ),

        // Provides the PermissionHandler for Health Connect permissions.
        Provider<PermissionHandler>(create: (_) => PermissionHandler()),

        // Provides the HealthConnectSync service for data synchronization.
        Provider<HealthConnectSync>(
          create: (context) => HealthConnectSync(
            client: context.read<ApiClient>(),
            permissions: context.read<PermissionHandler>(),
          ),
        ),

        // Provides the SyncScheduler for managing background sync tasks.
        Provider<SyncScheduler>(create: (_) => SyncScheduler()),

        // Provides the AuthStateManager to manage the app's authentication state.
        // It's a ChangeNotifier, so widgets can listen for auth state changes.
        // Immediately attempts to log in the user automatically.
        ChangeNotifierProvider<AuthStateManager>(
          create: (context) => AuthStateManager(
            authRepo: context.read<AuthRepository>(),
            syncCoordinator: context.read<SyncScheduler>(),
          )..tryAutoLogin(),
        ),

        // Provides the LoginViewModel for the login screen.
        ChangeNotifierProvider<LoginViewModel>(
          create: (context) => LoginViewModel(
            authManager: context.read<AuthStateManager>(),
            authRepo: context.read<AuthRepository>(),
          ),
        ),

        // Provides the RegisterViewModel for the registration screen.
        ChangeNotifierProvider<RegisterViewModel>(
          create: (context) => RegisterViewModel(
            authManager: context.read<AuthStateManager>(),
            authRepo: context.read<AuthRepository>(),
          ),
        ),

        // Provides the ManualInputModelView for the manual input screen.
        ChangeNotifierProvider<ManualInputViewModel>(
          create: (context) => ManualInputViewModel(
            inputRepo: context.read<ManualInputRepository>(),
          ),
        ),
      ],

      // The root widget of the application.
      child: const DiabitsApp(),
    ),
  );
}