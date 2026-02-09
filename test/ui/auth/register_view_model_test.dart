import 'package:diabits_mobile/data/network/requests/register_request.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:diabits_mobile/ui/auth/register_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_view_model_test.mocks.dart';

@GenerateMocks([AuthStateManager])
void main() {
  late RegisterViewModel viewModel;
  late MockAuthStateManager mockAuthManager;

  setUp(() {
    mockAuthManager = MockAuthStateManager();
    viewModel = RegisterViewModel(authManager: mockAuthManager);
  });

  group('RegisterViewModel', () {
    test('initial state is correct', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.passwordHidden, isTrue);
      expect(viewModel.snackMessage, isNull);
    });

    test('togglePasswordVisibility toggles passwordHidden and notifies listeners', () {
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.togglePasswordVisibility();
      expect(viewModel.passwordHidden, isFalse);
      expect(notifyCount, 1);

      viewModel.togglePasswordVisibility();
      expect(viewModel.passwordHidden, isTrue);
      expect(notifyCount, 2);
    });

    test('clearSnack sets snackMessage to null', () async {
      when(mockAuthManager.register(any)).thenAnswer((_) async => 'Error');

      await viewModel.submit(
        username: 'test',
        password: 'password',
        email: 'test@example.com',
        inviteCode: '123',
      );

      expect(viewModel.snackMessage, 'Error');
      viewModel.clearSnack();
      expect(viewModel.snackMessage, isNull);
    });

    test('submit sets loading state and calls authManager.register', () async {
      when(mockAuthManager.register(any)).thenAnswer((_) async => null);

      final future = viewModel.submit(
        username: 'user',
        password: 'password',
        email: 'email@test.com',
        inviteCode: 'code',
      );

      expect(viewModel.isLoading, isTrue);

      await future;

      expect(viewModel.isLoading, isFalse);
      verify(
        mockAuthManager.register(
          argThat(
            predicate<RegisterRequest>(
              (r) =>
                  r.username == 'user' &&
                  r.password == 'password' &&
                  r.email == 'email@test.com' &&
                  r.inviteCode == 'code',
            ),
          ),
        ),
      ).called(1);
    });

    test('submit sets snackMessage on failure', () async {
      when(mockAuthManager.register(any)).thenAnswer((_) async => 'Invalid invite code');

      await viewModel.submit(
        username: 'user',
        password: 'password',
        email: 'email@test.com',
        inviteCode: 'wrong',
      );

      expect(viewModel.snackMessage, 'Invalid invite code');
    });

    test('submit does nothing if already loading', () async {
      when(mockAuthManager.register(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return null;
      });

      final firstCall = viewModel.submit(
        username: 'u1',
        password: 'p1',
        email: 'e1',
        inviteCode: 'c1',
      );
      expect(viewModel.isLoading, isTrue);

      await viewModel.submit(username: 'u2', password: 'p2', email: 'e2', inviteCode: 'c2');

      await firstCall;

      verify(mockAuthManager.register(any)).called(1);
    });
  });
}
