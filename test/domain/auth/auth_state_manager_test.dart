import 'package:diabits_mobile/data/auth/auth_repository.dart';
import 'package:diabits_mobile/data/auth/dtos/auth_result.dart';
import 'package:diabits_mobile/data/health_connect/sync_scheduler.dart';
import 'package:diabits_mobile/data/network/requests/login_request.dart';
import 'package:diabits_mobile/data/network/requests/register_request.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_state_manager_test.mocks.dart';

@GenerateMocks([AuthRepository, SyncScheduler])
void main() {
  late AuthStateManager authStateManager;
  late MockAuthRepository mockAuthRepo;
  late MockSyncScheduler mockSyncScheduler;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockSyncScheduler = MockSyncScheduler();
    authStateManager = AuthStateManager(
      authRepo: mockAuthRepo,
      syncCoordinator: mockSyncScheduler,
    );
  });

  group('AuthStateManager', () {
    test('initial state is AuthState.none', () {
      expect(authStateManager.authState, AuthState.none);
    });

    group('login', () {
      test('updates state and starts sync on success', () async {
        final request = LoginRequest(username: 'user', password: 'pass');
        when(mockAuthRepo.login(request)).thenAnswer((_) async => AuthResult(true, null));
        when(mockSyncScheduler.startBackgroundSync()).thenAnswer((_) async => {});

        final message = await authStateManager.login(request);

        expect(authStateManager.authState, AuthState.authenticated);
        expect(message, isNull);
        verify(mockSyncScheduler.startBackgroundSync()).called(1);
      });

      test('remains unauthenticated and returns message on failure', () async {
        final request = LoginRequest(username: 'user', password: 'pass');
        when(mockAuthRepo.login(request)).thenAnswer((_) async => AuthResult(false, 'Error'));

        final message = await authStateManager.login(request);

        expect(authStateManager.authState, AuthState.none);
        expect(message, 'Error');
        verifyNever(mockSyncScheduler.startBackgroundSync());
      });
    });

    group('register', () {
      test('updates state and starts sync on success', () async {
        final request = RegisterRequest(
          username: 'u', password: 'p', email: 'e', inviteCode: 'c'
        );
        when(mockAuthRepo.register(request)).thenAnswer((_) async => AuthResult(true, null));
        when(mockSyncScheduler.startBackgroundSync()).thenAnswer((_) async => {});

        final message = await authStateManager.register(request);

        expect(authStateManager.authState, AuthState.authenticated);
        expect(message, isNull);
        verify(mockSyncScheduler.startBackgroundSync()).called(1);
      });
    });

    group('logout', () {
      test('updates state and stops sync', () async {
        when(mockAuthRepo.logout()).thenAnswer((_) async => {});
        when(mockSyncScheduler.stopBackgroundSync()).thenAnswer((_) async => {});

        await authStateManager.logout();

        expect(authStateManager.authState, AuthState.unauthenticated);
        verify(mockSyncScheduler.stopBackgroundSync()).called(1);
      });
    });

    group('tryAutoLogin', () {
      test('sets unauthenticated if no tokens', () async {
        when(mockAuthRepo.hasTokens()).thenAnswer((_) async => false);

        await authStateManager.tryAutoLogin();

        expect(authStateManager.authState, AuthState.unauthenticated);
      });

      test('sets authenticated optimistically then validates', () async {
        when(mockAuthRepo.hasTokens()).thenAnswer((_) async => true);
        when(mockAuthRepo.autoLogin()).thenAnswer((_) async => AuthState.authenticated);
        when(mockSyncScheduler.startBackgroundSync()).thenAnswer((_) async => {});

        await authStateManager.tryAutoLogin();

        expect(authStateManager.authState, AuthState.authenticated);
        verify(mockSyncScheduler.startBackgroundSync()).called(1);
      });

      test('reverts to unauthenticated if token validation fails', () async {
        when(mockAuthRepo.hasTokens()).thenAnswer((_) async => true);
        when(mockAuthRepo.autoLogin()).thenAnswer((_) async => AuthState.unauthenticated);

        await authStateManager.tryAutoLogin();

        expect(authStateManager.authState, AuthState.unauthenticated);
        verifyNever(mockSyncScheduler.startBackgroundSync());
      });
    });
  });
}