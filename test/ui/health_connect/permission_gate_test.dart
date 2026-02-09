import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:diabits_mobile/ui/health_connect/permission_gate.dart';
import 'package:diabits_mobile/ui/manual_input/manual_input_screen.dart';
import 'package:diabits_mobile/ui/manual_input/manual_input_view_model.dart';
import 'package:diabits_mobile/ui/shared/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'permission_gate_test.mocks.dart';

@GenerateMocks([PermissionHandler, AuthStateManager, ManualInputRepository])
void main() {
  late MockPermissionHandler mockPermissionHandler;
  late MockAuthStateManager mockAuthManager;
  late MockManualInputRepository mockInputRepo;
  late ManualInputViewModel manualInputViewModel;

  setUp(() {
    mockPermissionHandler = MockPermissionHandler();
    mockAuthManager = MockAuthStateManager();
    mockInputRepo = MockManualInputRepository();
    manualInputViewModel = ManualInputViewModel(inputRepo: mockInputRepo);

    // Stub the initial data load that happens in ManualInputScreen's initState while mocking tests
    when(mockInputRepo.getManualInputForDay(any)).thenAnswer((_) async => null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          Provider<PermissionHandler>.value(value: mockPermissionHandler),
          ChangeNotifierProvider<AuthStateManager>.value(value: mockAuthManager),
          ChangeNotifierProvider<ManualInputViewModel>.value(
            value: manualInputViewModel,
          ),
        ],
        child: const PermissionGate(),
      ),
    );
  }

  group('PermissionGate', () {
    testWidgets('shows LoadingScreen while checking permissions', (tester) async {
      when(mockPermissionHandler.requestPermissions()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return true;
      });

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(LoadingScreen), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows ManualInputScreen when permissions are granted', (tester) async {
      when(mockPermissionHandler.requestPermissions()).thenAnswer((_) async => true);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ManualInputScreen), findsOneWidget);
      verify(mockInputRepo.getManualInputForDay(any)).called(1);
    });

    testWidgets('shows permission request UI when permissions are denied', (tester) async {
      when(mockPermissionHandler.requestPermissions()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Health Connect Permissions Required'), findsOneWidget);
      expect(find.text('Open System Settings'), findsOneWidget);
    });

    testWidgets('retries permission check when "Grant Permissions" is pressed', (tester) async {
      // First call fails
      when(mockPermissionHandler.requestPermissions()).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Second call succeeds
      when(mockPermissionHandler.requestPermissions()).thenAnswer((_) async => true);

      await tester.tap(find.text('Grant Permissions'));
      await tester.pumpAndSettle();

      expect(find.byType(ManualInputScreen), findsOneWidget);
      verify(mockPermissionHandler.requestPermissions()).called(2);
    });
  });
}
