import 'package:diabits_mobile/data/manual_input/dtos/manual_input_dto.dart';
import 'package:diabits_mobile/data/manual_input/dtos/medication_value_input.dart';
import 'package:diabits_mobile/ui/manual_input/managers/medication_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MedicationManager manager;
  final testDate = DateTime(2026, 12, 31);

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
        manager.add('Panodil', 5, testDate);

        expect(manager.medications, hasLength(1));
        expect(manager.medications.first.name, 'Panodil');
        expect(manager.isDirty, isTrue);
      });

      test('New medications are included in buildCreateRequests', () {
        manager.add('Panodil', 5, testDate);

        final requests = manager.buildCreateRequests();
        expect(requests, hasLength(1));
        expect(requests.first.type, 'MEDICATION');
        expect(requests.first.medication?.name, 'Panodil');
        expect(requests.first.id, isNull);
      });
    });

    group('Loading and updating medications', () {
      final originalDto = ManualInputDto(
        id: 101,
        type: 'MEDICATION',
        dateFrom: testDate,
        medication: MedicationValueInput(name: 'Ipren', amount: 2),
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
        manager.update(101, 'Ipren', 5, testDate);

        expect(manager.isDirty, isTrue);
        expect(manager.medications.first.amount, 5);

        final updates = manager.buildUpdateRequests();
        expect(updates, hasLength(1));
        expect(updates.first.id, 101);
        expect(updates.first.medication?.amount, 5);
      });

      test('Updating back to original values clears dirty state', () {
        manager.update(101, 'Ipren', 222, testDate);
        expect(manager.isDirty, isTrue);

        manager.update(101, 'Ipren', 2, testDate);
        expect(manager.isDirty, isFalse);
        expect(manager.buildUpdateRequests(), isEmpty);
      });
    });

    group('Removing medications', () {
      test('Removing an unsaved medication removes it from the list', () {
        manager.add('Panodil', 2, testDate);
        final tempId = manager.medications.first.id;

        manager.removeById(tempId);

        expect(manager.medications, isEmpty);
        expect(manager.isDirty, isFalse);
        expect(manager.toDeleteIds, isEmpty);
      });

      test('Removing a saved medication tracks it for deletion', () {
        final dto = ManualInputDto(
          id: 202,
          type: 'MEDICATION',
          dateFrom: testDate,
          medication: MedicationValueInput(name: 'Treo', amount: 1),
        );
        manager.loadFromDto([dto]);

        manager.removeById(202);

        expect(manager.medications, isEmpty);
        expect(manager.isDirty, isTrue);
        expect(manager.toDeleteIds, contains(202));
      });
    });

    test('clear() resets all state', () {
      manager.add('Panodil', 5, testDate);
      manager.clear();

      expect(manager.medications, isEmpty);
      expect(manager.isDirty, isFalse);
      expect(manager.toDeleteIds, isEmpty);
    });
  });
}
