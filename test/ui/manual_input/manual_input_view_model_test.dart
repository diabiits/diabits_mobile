import 'package:diabits_mobile/data/manual_input/dtos/manual_input_dto.dart';
import 'package:diabits_mobile/data/manual_input/dtos/medication_value_input.dart';
import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:diabits_mobile/data/network/requests/manual_input_request.dart';
import 'package:diabits_mobile/data/network/responses/manual_input_response.dart';
import 'package:diabits_mobile/domain/models/medication_input.dart';
import 'package:diabits_mobile/ui/manual_input/manual_input_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'manual_input_view_model_test.mocks.dart';

@GenerateMocks([ManualInputRepository])
void main() {
  late ManualInputViewModel viewModel;
  late MockManualInputRepository mockRepo;
  final testDate = DateTime(2026, 12, 31);

  setUp(() {
    mockRepo = MockManualInputRepository();
    viewModel = ManualInputViewModel(inputRepo: mockRepo);
  });

  group('ManualInputViewModel', () {
    test('startEditing(medication) sets active editing medication and notifies listeners', () {
      final med = MedicationInput.fromDto(TestData.med(testDate, id: 1));
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.startEditing(med);

      expect(viewModel.activeEditingMedication, med);
      expect(notifyCount, 1);
    });

    test('cancelEditing() clears active editing medication and notifies listeners', () {
      viewModel.startEditing(MedicationInput.fromDto(TestData.med(testDate)));
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.cancelEditing();

      expect(viewModel.activeEditingMedication, isNull);
      expect(notifyCount, 1);
    });

    test(
      'saveMedication(name, amount, time) updates existing medication when activeEditingMedication is set',
      () {
        viewModel.medicationManager.loadFromDto([TestData.med(testDate, id: 10, name: 'Ipren')]);
        viewModel.startEditing(viewModel.medicationManager.medications.first);

        viewModel.saveMedication('Panodil', 2, testDate);

        expect(viewModel.activeEditingMedication, isNull);
        expect(viewModel.medicationManager.medications.first.name, 'Panodil');
        expect(viewModel.medicationManager.isDirty, isTrue);
      },
    );

    test('loadDataForSelectedDate() loads managers when repository returns data', () async {
      final response = TestData.response(
        meds: [TestData.med(testDate, name: 'Treo')],
        mens: TestData.mens(testDate),
      );

      when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => response);

      await viewModel.loadDataForSelectedDate();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.medicationManager.medications, hasLength(1));
      expect(viewModel.medicationManager.medications.first.name, 'Treo');
      expect(viewModel.menstruationManager.menstruation, isNotNull);
    });

    test('loadDataForSelectedDate() clears managers when repository returns null', () async {
      viewModel.medicationManager.add('Panodil', 2, testDate);
      when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => null);

      await viewModel.loadDataForSelectedDate();

      expect(viewModel.medicationManager.medications, isEmpty);
      expect(viewModel.menstruationManager.menstruation, isNull);
    });

    test(
      'submit() calls relevant repository methods when there are deletions, updates, and creations',
      () async {
        final initialResponse = TestData.response(
          meds: [TestData.med(testDate, id: 10, name: 'Ipren')],
          mens: TestData.mens(testDate, id: 20),
        );

        when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => initialResponse);
        await viewModel.loadDataForSelectedDate();

        viewModel.saveMedication('Panodil', 2, testDate);
        viewModel.startEditing(
          viewModel.medicationManager.medications.firstWhere((m) => m.id == 10),
        );
        viewModel.saveMedication('Ipren', 4, testDate);
        viewModel.toggleMenstruation(false);

        when(mockRepo.submitManualInputs(any)).thenAnswer((_) async => true);
        when(mockRepo.updateManualInputs(any)).thenAnswer((_) async => true);
        when(mockRepo.deleteManualInputs(any)).thenAnswer((_) async => true);
        when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => TestData.response());

        await viewModel.submit();

        verify(
          mockRepo.deleteManualInputs(
            argThat(predicate<ManualInputDeleteRequest>((r) => r.ids.contains(20))),
          ),
        ).called(1);
        verify(
          mockRepo.updateManualInputs(
            argThat(predicate<ManualInputRequest>((r) => r.items.any((i) => i.id == 10))),
          ),
        ).called(1);
        verify(
          mockRepo.submitManualInputs(
            argThat(
              predicate<ManualInputRequest>(
                (r) => r.items.any((i) => i.medication?.name == 'Panodil'),
              ),
            ),
          ),
        ).called(1);
      },
    );

    test('submit() always clears isLoading when repository throws', () async {
      viewModel.toggleMenstruation(true);
      when(mockRepo.submitManualInputs(any)).thenThrow(Exception('Error'));

      expect(() => viewModel.submit(), throwsException);
      await pumpEventQueue();
      expect(viewModel.isLoading, isFalse);
    });
  });
}

class TestData {
  static ManualInputDto med(DateTime date, {int id = 1, String name = 'Med'}) => ManualInputDto(
    id: id,
    type: 'MEDICATION',
    dateFrom: date,
    medication: MedicationValueInput(name: name, amount: 2),
  );

  static ManualInputDto mens(DateTime date, {int id = 1}) =>
      ManualInputDto(id: id, type: 'MENSTRUATION', dateFrom: date, flow: 'MEDIUM');

  static ManualInputResponse response({
    List<ManualInputDto> meds = const [],
    ManualInputDto? mens,
  }) => ManualInputResponse(medications: meds, menstruation: mens);
}
