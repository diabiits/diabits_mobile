import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:diabits_mobile/data/network/api_client.dart';
import 'package:diabits_mobile/data/network/dtos/api_result.dart';
import 'package:diabits_mobile/data/network/requests/manual_input_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'manual_input_repository_test.mocks.dart';

@GenerateMocks([ApiClient])
void main() {
  late ManualInputRepository repository;
  late MockApiClient mockClient;
  final testDate = DateTime(2026, 12, 31);

  setUp(() {
    mockClient = MockApiClient();
    repository = ManualInputRepository(client: mockClient);
  });

  group('ManualInputRepository', () {
    test('getManualInputForDay returns data on success', () async {
      final responseBody = {'medications': [], 'menstruation': null};
      when(
        mockClient.get(any, params: anyNamed('params')),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200, body: responseBody));

      final result = await repository.getManualInputForDay(testDate);

      expect(result, isNotNull);
      verify(
        mockClient.get(
          any,
          params: argThat(
            predicate<Map<String, String>>((p) => p.containsKey('date')),
            named: 'params',
          ),
        ),
      ).called(1);
    });

    test('submitManualInputs returns true on success', () async {
      when(
        mockClient.post(any, any),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200));

      final result = await repository.submitManualInputs(ManualInputRequest(items: []));

      expect(result, isTrue);
      verify(mockClient.post(any, any)).called(1);
    });

    test('updateManualInputs returns true on success', () async {
      when(
        mockClient.put(any, any),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200));

      final result = await repository.updateManualInputs(ManualInputRequest(items: []));

      expect(result, isTrue);
      verify(mockClient.put(any, any)).called(1);
    });

    test('deleteManualInputs returns true on success', () async {
      when(
        mockClient.delete(any, body: anyNamed('body')),
      ).thenAnswer((_) async => ApiResult(success: true, statusCode: 200));

      final result = await repository.deleteManualInputs(ManualInputDeleteRequest(ids: [1]));

      expect(result, isTrue);
      verify(mockClient.delete(any, body: anyNamed('body'))).called(1);
    });
  });
}
