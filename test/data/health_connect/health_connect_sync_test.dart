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
    test('runSync() sends data to backend if found', () async {
      when(mockPermissions.initHealthConnect()).thenAnswer((_) async => mockHealth);
      when(mockClient.get(any)).thenAnswer(
        (_) async =>
            ApiResult(success: true, statusCode: 200, body: {'lastSyncAt': '2025-12-31T00:00:00Z'}),
      );

      final mockDataPoint = HealthDataPoint(
        value: NumericHealthValue(numericValue: 6.0),
        type: HealthDataType.BLOOD_GLUCOSE,
        unit: HealthDataUnit.MILLIMOLES_PER_LITER,
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
          preferredUnits: anyNamed('preferredUnits'),
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

    test('runSync() skips if lastSync API call never goes through', () async {
      when(mockPermissions.initHealthConnect()).thenAnswer((_) async => mockHealth);
      when(mockClient.get(any)).thenAnswer((_) async => ApiResult(success: false, statusCode: 503));

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
  });
}
