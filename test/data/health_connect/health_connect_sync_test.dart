import 'package:diabits_mobile/data/health_connect/health_connect_sync.dart';
import 'package:diabits_mobile/data/health_connect/permission_handler.dart';
import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:diabits_mobile/data/network/dtos/api_result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'health_connect_sync_test.mocks.dart';

@GenerateMocks([ApiClient, PermissionHandler, Health])
void main() {
  late HealthConnectSync sync;
  late MockApiClient mockClient;
  late MockPermissionHandler mockPermissions;
  late MockHealth mockHealth;

  setUp(() {
    mockClient = MockApiClient();
    mockPermissions = MockPermissionHandler();
    mockHealth = MockHealth();
    sync = HealthConnectSync(client: mockClient, permissions: mockPermissions);
  });

  group('HealthConnectSync', () {
    test('runSync() handles first-time sync (404 on lastSync)', () async {
      when(mockPermissions.initHealthConnect()).thenAnswer((_) async => mockHealth);

      // Mock lastSync returning 404
      when(mockClient.get(any)).thenAnswer((_) async => ApiResult(success: false, statusCode: 404));

      when(
        mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer((_) async => []);

      when(mockHealth.removeDuplicates(any)).thenReturn([]);

      final result = await sync.runSync();

      expect(result, isTrue); // Success because nothing to sync is still success
      verify(
        mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: argThat(isA<DateTime>(), named: 'startTime'),
          endTime: argThat(isA<DateTime>(), named: 'endTime'),
        ),
      ).called(1);
    });

    test('runSync() skips if lastSync API fails (e.g. 500)', () async {
      when(mockPermissions.initHealthConnect()).thenAnswer((_) async => mockHealth);
      when(mockClient.get(any)).thenAnswer((_) async => ApiResult(success: false, statusCode: 500));

      final result = await sync.runSync();

      expect(result, isFalse);
      verifyNever(
        mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      );
    });

    test('runSync() sends data to backend if found', () async {
      when(mockPermissions.initHealthConnect()).thenAnswer((_) async => mockHealth);
      when(mockClient.get(any)).thenAnswer(
        (_) async =>
            ApiResult(success: true, statusCode: 200, body: {'lastSyncAt': '2023-01-01T00:00:00Z'}),
      );

      final mockDataPoint = HealthDataPoint(
        value: NumericHealthValue(numericValue: 100),
        type: HealthDataType.BLOOD_GLUCOSE,
        unit: HealthDataUnit.MILLIGRAM_PER_DECILITER,
        dateFrom: DateTime.now(),
        dateTo: DateTime.now(),
        sourceId: 'sourceId',
        sourceName: 'sourceName',
        uuid: '',
        sourcePlatform: HealthPlatformType.googleHealthConnect,
        sourceDeviceId: '',
      );

      when(
        mockHealth.getHealthDataFromTypes(
          types: anyNamed('types'),
          startTime: anyNamed('startTime'),
          endTime: anyNamed('endTime'),
        ),
      ).thenAnswer((_) async => [mockDataPoint]);

      when(mockHealth.removeDuplicates(any)).thenReturn([mockDataPoint]);

      when(
        mockClient.post(any, any, timeout: anyNamed('timeout')),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200));

      final result = await sync.runSync();

      expect(result, isTrue);
      verify(mockClient.post(any, any, timeout: anyNamed('timeout'))).called(1);
    });
  });
}
