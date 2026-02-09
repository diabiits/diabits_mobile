import 'package:diabits_mobile/ui/shared/auth_gate.dart';
import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:diabits_mobile/ui/auth/login_screen.dart';
import 'package:diabits_mobile/ui/auth/login_view_model.dart';
import 'package:diabits_mobile/ui/health_connect/permission_gate.dart';
import 'package:diabits_mobile/ui/shared/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'auth_gate_test.mocks.dart';

@GenerateMocks([AuthStateManager, LoginViewModel, PermissionHandler])
void main() {
  late MockAuthStateManager mockAuthManager;
  late MockLoginViewModel mockLoginViewModel;
  late MockPermissionHandler mockPermissionHandler;

  setUp(() {
    mockAuthManager = MockAuthStateManager();
    mockLoginViewModel = MockLoginViewModel();
    mockPermissionHandler = MockPermissionHandler();

    // Stub default values for the mocked LoginViewModel to avoid null errors during build
    when(mockLoginViewModel.isLoading).thenReturn(false);
    when(mockLoginViewModel.passwordHidden).thenReturn(true);
    when(mockLoginViewModel.snackMessage).thenReturn(null);
    
    // Stub requestPermissions to avoid MissingStubError when PermissionGate is built
    when(mockPermissionHandler.requestPermissions()).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthStateManager>.value(value: mockAuthManager),
          ChangeNotifierProvider<LoginViewModel>.value(value: mockLoginViewModel),
          Provider<PermissionHandler>.value(value: mockPermissionHandler),
        ],
        child: const AuthGate(),
      ),
    );
  }

  group('AuthGate', () {
    testWidgets('shows LoadingScreen when state is AuthState.none', (tester) async {
      when(mockAuthManager.authState).thenReturn(AuthState.none);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(LoadingScreen), findsOneWidget);
    });

    testWidgets('shows LoginScreen when state is AuthState.unauthenticated', (tester) async {
      when(mockAuthManager.authState).thenReturn(AuthState.unauthenticated);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('shows PermissionGate when state is AuthState.authenticated', (tester) async {
      when(mockAuthManager.authState).thenReturn(AuthState.authenticated);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(PermissionGate), findsOneWidget);
    });
  });
}
