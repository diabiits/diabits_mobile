import 'dart:convert';
import 'package:diabits_mobile/data/auth/token_storage.dart';
import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:diabits_mobile/domain/auth/auth_event_broadcaster.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'api_client_test.mocks.dart';

@GenerateMocks([TokenStorage, http.Client])
void main() {
  late ApiClient apiClient;
  late MockTokenStorage mockTokens;
  late MockClient mockHttpClient;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.loadFromString(envString: 'BASE_URL=https://api.test.com');
  });

  setUp(() {
    mockTokens = MockTokenStorage();
    mockHttpClient = MockClient();
    apiClient = ApiClient(tokens: mockTokens, httpClient: mockHttpClient);
  });

  group('ApiClient', () {
    test('get() sends request with authorization header', () async {
      when(mockTokens.getAccessToken()).thenAnswer((_) async => 'valid_token');
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('{"data": "ok"}', 200));

      final result = await apiClient.get('/test');

      expect(result.success, isTrue);
      expect(result.body['data'], 'ok');
      
      final capturedHeaders = verify(mockHttpClient.get(any, headers: captureAnyNamed('headers')))
          .captured.first as Map<String, String>;
      expect(capturedHeaders['Authorization'], 'Bearer valid_token');
    });

    test('automatic token refresh on 401', () async {
      when(mockTokens.getAccessToken()).thenAnswer((_) async => 'expired_token');
      when(mockTokens.getRefreshToken()).thenAnswer((_) async => 'valid_refresh');
      
      // First call returns 401
      // Second call (refresh) returns 200
      // Third call (retry) returns 200
      int callCount = 0;
      when(mockHttpClient.get(any, headers: anyNamed('headers'))).thenAnswer((_) async {
        callCount++;
        return callCount == 1 
            ? http.Response('Unauthorized', 401)
            : http.Response('{"data": "ok"}', 200);
      });

      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(
                jsonEncode({
                  'accessToken': 'new_access', 
                  'refreshToken': 'new_refresh',
                  'expiresAt': DateTime.now().add(const Duration(hours: 1)).toIso8601String(),
                }), 
                200
              ));

      final result = await apiClient.get('/test');

      expect(result.success, isTrue);
      verify(mockTokens.saveAccessToken('new_access')).called(1);
      verify(mockTokens.saveRefreshToken('new_refresh')).called(1);
      expect(callCount, 2); // Initial fail + Retry
    });

    test('broadcasts loginNeeded if refresh also returns 401', () async {
      when(mockTokens.getAccessToken()).thenAnswer((_) async => 'expired_token');
      when(mockTokens.getRefreshToken()).thenAnswer((_) async => 'expired_refresh');
      
      when(mockHttpClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));
      
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('Unauthorized', 401));

      // Listen to auth events
      AuthEvent? capturedEvent;
      final sub = authEvents.stream.listen((e) => capturedEvent = e);

      final result = await apiClient.get('/test');

      expect(result.success, isFalse);
      expect(result.statusCode, 401);
      
      // Wait for stream event to be delivered
      await pumpEventQueue();
      
      expect(capturedEvent, AuthEvent.loginNeeded);
      sub.cancel();
    });

    test('post() handles server errors and decodes message', () async {
      when(mockTokens.getAccessToken()).thenAnswer((_) async => null);
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response('{"message": "Validation failed"}', 400));

      final result = await apiClient.post('/test', {'foo': 'bar'});

      expect(result.success, isFalse);
      expect(result.statusCode, 400);
      expect(result.message, 'Validation failed');
    });
  });
}
