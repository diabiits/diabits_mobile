import 'package:diabits_mobile/domain/models/medication_input.dart';
import 'package:diabits_mobile/ui/manual_input/managers/medication_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import '../manual_input_test_data.dart';

void main() {
  late MedicationManager manager;
  final date = DateTime(2026, 12, 31);

  setUp(() {
    manager = MedicationManager();
  });

  group('MedicationManager', () {
    test('Initial state is clean', () {
      expect(manager.medications, isEmpty);
      expect(manager.isDirty, isFalse);
      expect(manager.toDeleteIds, isEmpty);
    });

    group('Adding medications', () {
      test('add() increases list and marks manager as dirty', () {
        manager.add(
          name: 'Panodil',
          quantity: 2,
          strengthValue: 500,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );

        expect(manager.medications, hasLength(1));
        expect(manager.medications.first.name, 'Panodil');
        expect(manager.isDirty, isTrue);
      });

      test('New medications are included in buildCreateRequests', () {
        manager.add(
          name: 'Panodil',
          quantity: 2,
          strengthValue: 500,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );

        final requests = manager.buildCreateRequests();
        expect(requests, hasLength(1));
        expect(requests.first.type, 'MEDICATION');
        expect(requests.first.medication?.name, 'Panodil');
        expect(requests.first.id, isNull);
      });
    });

    group('Loading and updating medications', () {
      final originalDto = ManualInputTestData.med(
        date,
        id: 101,
        name: 'Ipren',
        quantity: 2,
        strengthValue: 400,
        strengthUnit: 'MG',
      );

      setUp(() {
        manager.loadFromDto([originalDto]);
      });

      test('loadFromDto populates the manager and is not dirty', () {
        expect(manager.medications, hasLength(1));
        expect(manager.medications.first.id, 101);
        expect(manager.medications.first.isSavedInDatabase, isTrue);
        expect(manager.isDirty, isFalse);
      });

      test('Updating a loaded medication marks manager as dirty', () {
        manager.update(
          id: 101,
          name: 'Ipren',
          quantity: 5,
          strengthValue: 400,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );

        expect(manager.isDirty, isTrue);
        expect(manager.medications.first.quantity, 5);

        final updates = manager.buildUpdateRequests();
        expect(updates, hasLength(1));
        expect(updates.first.id, 101);
        expect(updates.first.medication?.quantity, 5);
      });

      test('Updating back to original values clears dirty state', () {
        manager.update(
          id: 101,
          name: 'Ipren',
          quantity: 222,
          strengthValue: 400,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );
        expect(manager.isDirty, isTrue);

        manager.update(
          id: 101,
          name: 'Ipren',
          quantity: 2,
          strengthValue: 400,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );
        expect(manager.isDirty, isFalse);
        expect(manager.buildUpdateRequests(), isEmpty);
      });
    });

    group('Removing medications', () {
      test('Removing an unsaved medication removes it from the list', () {
        manager.add(
          name: 'Panodil',
          quantity: 2,
          strengthValue: 500,
          strengthUnit: StrengthUnit.mg,
          time: date,
        );
        final tempId = manager.medications.first.id;

        manager.removeById(tempId);

        expect(manager.medications, isEmpty);
        expect(manager.isDirty, isFalse);
        expect(manager.toDeleteIds, isEmpty);
      });

      test('Removing a saved medication tracks it for deletion', () {
        final dto = ManualInputTestData.med(date, id: 202);
        manager.loadFromDto([dto]);

        manager.removeById(202);

        expect(manager.medications, isEmpty);
        expect(manager.isDirty, isTrue);
        expect(manager.toDeleteIds, contains(202));
      });
    });

    test('clear() resets all state', () {
      manager.add(
        name: 'Panodil',
        quantity: 5,
        strengthValue: 500,
        strengthUnit: StrengthUnit.mg,
        time: date,
      );
      manager.clear();

      expect(manager.medications, isEmpty);
      expect(manager.isDirty, isFalse);
      expect(manager.toDeleteIds, isEmpty);
    });
  });
}
