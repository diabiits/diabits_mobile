import 'package:diabits_mobile/data/auth/auth_repository.dart';
import 'package:diabits_mobile/data/auth/token_storage.dart';
import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:diabits_mobile/data/network/dtos/api_result.dart';
import 'package:diabits_mobile/data/network/requests/login_request.dart';
import 'package:diabits_mobile/data/network/requests/register_request.dart';
import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([ApiClient, TokenStorage])
void main() {
  late AuthRepository repository;
  late MockApiClient mockClient;
  late MockTokenStorage mockTokens;

  setUp(() {
    mockClient = MockApiClient();
    mockTokens = MockTokenStorage();
    repository = AuthRepository(client: mockClient, tokens: mockTokens);
  });

  group('AuthRepository', () {
    final successResponseBody = {
      'accessToken': 'at',
      'refreshToken': 'rt',
      'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
    };

    test('login() saves tokens on success', () async {
      final request = LoginRequest(username: 'test', password: 'password');

      when(
        mockClient.post(any, any),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200, body: successResponseBody));

      final result = await repository.login(request);

      expect(result.success, isTrue);
      verify(mockTokens.saveAccessToken('at')).called(1);
      verify(mockTokens.saveRefreshToken('rt')).called(1);
    });

    test('register() saves tokens on success', () async {
      final request = RegisterRequest(
        username: 'u',
        password: 'p',
        email: 'e@e.com',
        inviteCode: '123',
      );

      when(
        mockClient.post(any, any),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200, body: successResponseBody));

      final result = await repository.register(request);

      expect(result.success, isTrue);
      verify(mockTokens.saveAccessToken('at')).called(1);
      verify(mockTokens.saveRefreshToken('rt')).called(1);
    });

    test('login() returns failure result on API error', () async {
      when(
        mockClient.post(any, any),
      ).thenAnswer((_) async => ApiResult(success: false, statusCode: 400, message: 'Invalid'));

      final result = await repository.login(LoginRequest(username: 'u', password: 'p'));

      expect(result.success, isFalse);
      expect(result.message, 'Invalid');
      verifyNever(mockTokens.saveAccessToken(any));
    });

    test('logout() clears tokens and calls API', () async {
      when(mockTokens.getRefreshToken()).thenAnswer((_) async => 'rt');
      when(
        mockClient.post(any, any),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200));

      await repository.logout();

      verify(mockClient.post(any, argThat(containsValue('rt')))).called(1);
      verify(mockTokens.clearAll()).called(1);
    });

    test('autoLogin() returns correct AuthState based on API result', () async {
      when(mockClient.get(any)).thenAnswer((_) async => ApiResult(success: true, statusCode: 200));
      expect(await repository.autoLogin(), AuthState.authenticated);

      when(mockClient.get(any)).thenAnswer((_) async => ApiResult(success: false, statusCode: 401));
      expect(await repository.autoLogin(), AuthState.unauthenticated);

      when(mockClient.get(any)).thenAnswer((_) async => ApiResult(success: false, statusCode: 503));
      expect(await repository.autoLogin(), isNull);
    });
  });
}
