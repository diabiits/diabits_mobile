import 'package:diabits_mobile/data/manual_input/dtos/manual_input_dto.dart';
import 'package:diabits_mobile/ui/manual_input/managers/menstruation_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MenstruationManager manager;
  final testDate = DateTime(2026, 12, 31);

  setUp(() {
    manager = MenstruationManager();
  });

  group('MenstruationManager', () {
    test('Initial state is clean', () {
      expect(manager.menstruation, isNull);
      expect(manager.isDirty, isFalse);
      expect(manager.createDto, isNull);
      expect(manager.updateDto, isNull);
      expect(manager.idToDelete, isNull);
    });

    group('Creating new entries', () {
      test('setIsMenstruating(true) creates a new entry and marks manager as dirty', () {
        manager.setIsMenstruating(true, testDate);

        expect(manager.menstruation, isNotNull);
        expect(manager.menstruation!.flow, MenstruationManager.defaultFlow);
        expect(manager.isDirty, isTrue);
      });

      test('setIsMenstruating(true) produces a valid createDto', () {
        manager.setIsMenstruating(true, testDate);

        final dto = manager.createDto;
        expect(dto, isNotNull);
        expect(dto!.type, 'MENSTRUATION');
        expect(dto.flow, MenstruationManager.defaultFlow);
        expect(dto.id, isNull);

        expect(manager.updateDto, isNull);
        expect(manager.idToDelete, isNull);
      });

      test('Toggling menstruation on and off leaves the manager clean', () {
        manager.setIsMenstruating(true, testDate);
        manager.setIsMenstruating(false, testDate);

        expect(manager.menstruation, isNull);
        expect(manager.isDirty, isFalse);
        expect(manager.createDto, isNull);
      });
    });

    group('Loading and updating existing entries', () {
      final originalDto = ManualInputDto(
        id: 1,
        type: 'MENSTRUATION',
        dateFrom: testDate,
        flow: 'MEDIUM',
      );

      setUp(() {
        manager.loadFromDto(originalDto);
      });

      test('loadFromDto populates the manager and is not dirty', () {
        expect(manager.menstruation, isNotNull);
        expect(manager.menstruation!.id, 1);
        expect(manager.menstruation!.flow, 'MEDIUM');
        expect(manager.isDirty, isFalse);
      });

      test('Changing flow marks manager as dirty and creates an updateDto', () {
        manager.setFlow('HEAVY');

        expect(manager.isDirty, isTrue);
        expect(manager.menstruation!.flow, 'HEAVY');

        final dto = manager.updateDto;
        expect(dto, isNotNull);
        expect(dto!.id, 1);
        expect(dto.flow, 'HEAVY');

        expect(manager.createDto, isNull);
        expect(manager.idToDelete, isNull);
      });

      test('Changing flow back to original marks manager as clean', () {
        manager.setFlow('HEAVY');

        expect(manager.isDirty, isTrue);

        manager.setFlow('MEDIUM');

        expect(manager.isDirty, isFalse);
        expect(manager.updateDto, isNull);
        expect(manager.createDto, isNull);
      });
    });

    group('Loading and deleting existing entries', () {
      final originalDto = ManualInputDto(
        id: 1,
        type: 'MENSTRUATION',
        dateFrom: testDate,
        flow: 'MEDIUM',
      );

      setUp(() {
        manager.loadFromDto(originalDto);
      });

      test('setIsMenstruating(false) on a loaded entry tracks it for deletion', () {
        manager.setIsMenstruating(false, testDate);

        expect(manager.isDirty, isTrue);
        expect(manager.menstruation, isNull);
        expect(manager.idToDelete, 1);

        expect(manager.createDto, isNull);
        expect(manager.updateDto, isNull);
      });

      test('Deleting and then re-adding menstruation with default flow results in an update', () {
        manager.setIsMenstruating(false, testDate);
        manager.setIsMenstruating(true, testDate);

        expect(manager.isDirty, isTrue); // It's different from the original state
        expect(manager.idToDelete, isNull);
        expect(manager.updateDto, isNotNull);
        expect(manager.updateDto!.id, 1);
        // It should have the default flow since it was re-created
        expect(manager.updateDto!.flow, MenstruationManager.defaultFlow);
      });
    });

    test('clear() resets the state', () {
      manager.loadFromDto(
        ManualInputDto(id: 1, type: 'MENSTRUATION', dateFrom: testDate, flow: 'HEAVY'),
      );

      manager.clear();

      expect(manager.menstruation, isNull);
      expect(manager.isDirty, isFalse);
      expect(manager.createDto, isNull);
      expect(manager.updateDto, isNull);
      expect(manager.idToDelete, isNull);
    });
  });
}
