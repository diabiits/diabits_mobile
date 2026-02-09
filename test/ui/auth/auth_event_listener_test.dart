import 'package:diabits_mobile/domain/auth/auth_event_broadcaster.dart';
import 'package:diabits_mobile/ui/auth/auth_event_listener.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthEventListener', () {
    testWidgets('shows SnackBar when AuthEvent.loginNeeded is broadcasted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AuthEventListener(child: Container())),
        ),
      );

      authEvents.add(AuthEvent.loginNeeded);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Your session expired. Please log in again.'), findsOneWidget);
    });

    testWidgets('shows SnackBar when AuthEvent.serverUnavailable is broadcasted', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AuthEventListener(child: Container())),
        ),
      );

      authEvents.add(AuthEvent.serverUnavailable);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));

      expect(find.text('Server is currently unavailable.'), findsOneWidget);
    });
  });
}
