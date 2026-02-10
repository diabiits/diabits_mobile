import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:diabits_mobile/data/network/requests/manual_input_request.dart';
import 'package:diabits_mobile/domain/models/medication_input.dart';
import 'package:diabits_mobile/ui/manual_input/manual_input_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'manual_input_test_data.dart';
import 'manual_input_view_model_test.mocks.dart';

@GenerateMocks([ManualInputRepository])
void main() {
  late ManualInputViewModel viewModel;
  late MockManualInputRepository mockRepo;
  final date = DateTime(2026, 12, 31);

  setUp(() {
    mockRepo = MockManualInputRepository();
    viewModel = ManualInputViewModel(inputRepo: mockRepo);
  });

  group('ManualInputViewModel', () {
    test('startEditing() sets active editing medication and notifies listeners', () {
      final med = MedicationInput(
        name: 'med',
        quantity: 2,
        strengthValue: 500,
        strengthUnit: StrengthUnit.mg,
        time: date,
      );

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.startEditing(med);

      expect(viewModel.activeEditingMedication, med);
      expect(notifyCount, 1);
    });

    test('cancelEditing() clears active editing medication and notifies listeners', () {
      final med = MedicationInput(
        name: 'med',
        quantity: 2,
        strengthValue: 500,
        strengthUnit: StrengthUnit.mg,
        time: date,
      );

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.startEditing(med);
      viewModel.cancelEditing();

      expect(viewModel.activeEditingMedication, isNull);
      expect(notifyCount, 2);
    });

    test('saveMedication() updates existing medication when activeEditingMedication is set', () {
      viewModel.medicationManager.loadFromDto([ManualInputTestData.med(date, id: 10, name: 'Ipren')]);
      viewModel.startEditing(viewModel.medicationManager.medications.first);

      viewModel.saveMedication(
        name: 'Panodil',
        quantity: 2,
        strengthValue: 500,
        strengthUnit: StrengthUnit.mg,
        time: date,
      );

      expect(viewModel.activeEditingMedication, isNull);
      expect(viewModel.medicationManager.medications, hasLength(1));
      expect(viewModel.medicationManager.medications.first.name, 'Panodil');
      expect(viewModel.medicationManager.isDirty, isTrue);
    });

    test('saveMedication() adds new medication when activeEditingMedication is null', () {
      viewModel.medicationManager.loadFromDto([ManualInputTestData.med(date, id: 10, name: 'Ipren')]);

      viewModel.saveMedication(
        name: 'Panodil',
        quantity: 2,
        strengthValue: 500,
        strengthUnit: StrengthUnit.mg,
        time: date,
      );

      expect(viewModel.activeEditingMedication, isNull);
      expect(viewModel.medicationManager.medications, hasLength(2));
      expect(viewModel.medicationManager.isDirty, isTrue);
    });

    test('loadDataForSelectedDate() loads managers when repository returns data', () async {
      final response = ManualInputTestData.response(
        meds: [ManualInputTestData.med(date, name: 'Treo')],
        mens: ManualInputTestData.mens(date),
      );

      when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => response);

      await viewModel.loadDataForSelectedDate();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.medicationManager.medications, hasLength(1));
      expect(viewModel.medicationManager.medications.first.name, 'Treo');
      expect(viewModel.menstruationManager.menstruation, isNotNull);
    });

    test('loadDataForSelectedDate() clears managers when repository returns null', () async {
      viewModel.medicationManager.add(
        name: 'Panodil',
        quantity: 2,
        strengthValue: 500,
        strengthUnit: StrengthUnit.mg,
        time: date,
      );
      when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => null);

      await viewModel.loadDataForSelectedDate();

      expect(viewModel.medicationManager.medications, isEmpty);
      expect(viewModel.menstruationManager.menstruation, isNull);
    });

    test(
      'submit() calls relevant repository methods when there are deletions, updates, and creations',
      () async {
        final initialResponse = ManualInputTestData.response(
          meds: [ManualInputTestData.med(date, id: 10, name: 'Ipren')],
          mens: ManualInputTestData.mens(date, id: 20),
        );

        when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => initialResponse);
        await viewModel.loadDataForSelectedDate();

        // New medication
        viewModel.saveMedication(
          name: 'Panodil',
          quantity: 2,
          strengthValue: 500,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );
        // Update medication
        viewModel.startEditing(
          viewModel.medicationManager.medications.firstWhere((m) => m.id == 10),
        );
        viewModel.saveMedication(
          name: 'Ipren',
          quantity: 4,
          strengthValue: 500,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );
        //Delete menstruation
        viewModel.toggleMenstruation(false);

        when(mockRepo.submitManualInputs(any)).thenAnswer((_) async => true);
        when(mockRepo.updateManualInputs(any)).thenAnswer((_) async => true);
        when(mockRepo.deleteManualInputs(any)).thenAnswer((_) async => true);
        when(mockRepo.getManualInputForDay(any)).thenAnswer((_) async => ManualInputTestData.response());

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
