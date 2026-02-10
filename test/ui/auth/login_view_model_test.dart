import 'package:diabits_mobile/data/network/requests/login_request.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:diabits_mobile/ui/auth/login_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_view_model_test.mocks.dart';

@GenerateMocks([AuthStateManager])
void main() {
  late LoginViewModel viewModel;
  late MockAuthStateManager mockAuthManager;

  setUp(() {
    mockAuthManager = MockAuthStateManager();
    viewModel = LoginViewModel(authManager: mockAuthManager);
  });

  group('LoginViewModel', () {
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

    test('clearSnack sets snackMessage to null', () {
      when(mockAuthManager.login(any)).thenAnswer((_) async => 'Error');
      
      viewModel.submit(username: 'test', password: 'password').then((_) {
        expect(viewModel.snackMessage, 'Error');
        viewModel.clearSnack();
        expect(viewModel.snackMessage, isNull);
      });
    });

    test('submit sets loading state and calls authManager.login', () async {
      when(mockAuthManager.login(any)).thenAnswer((_) async => null);

      final future = viewModel.submit(username: 'user', password: 'password');
      
      expect(viewModel.isLoading, isTrue);
      
      await future;

      expect(viewModel.isLoading, isFalse);
      verify(mockAuthManager.login(argThat(predicate<LoginRequest>((r) => 
        r.username == 'user' && r.password == 'password'
      )))).called(1);
    });

    test('submit sets snackMessage on failure', () async {
      when(mockAuthManager.login(any)).thenAnswer((_) async => 'Invalid credentials');

      await viewModel.submit(username: 'user', password: 'wrong_password');

      expect(viewModel.snackMessage, 'Invalid credentials');
    });

    test('submit does nothing if already loading', () async {
      when(mockAuthManager.login(any)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return null;
      });

      final firstCall = viewModel.submit(username: 'user', password: 'password');
      expect(viewModel.isLoading, isTrue);

      await viewModel.submit(username: 'user2', password: 'password2');

      await firstCall;

      verify(mockAuthManager.login(any)).called(1);
    });
  });
}
