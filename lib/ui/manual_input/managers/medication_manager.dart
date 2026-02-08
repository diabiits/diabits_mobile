import 'package:diabits_mobile/data/manual_input/dtos/medication_value_input.dart';

import '../../../data/manual_input/dtos/manual_input_dto.dart';
import '../../../domain/models/medication_input.dart';

class MedicationManager {
  List<MedicationInput> medications = [];

  final Set<String> _toDelete = {};
  List<String> get medicationsToDelete => List.unmodifiable(_toDelete);

  // Snapshot for diffing. Only contains database-backed items.
  final Map<String, MedicationInput> _originalById = {};

  bool get isDirty =>
      _toDelete.isNotEmpty ||
      medications.any((m) => !m.isSavedInDatabase) ||
      medications.any(_isSavedAndChanged);

  // void loadFromDto(List<ManualInputDto> dtos) {
  //   medications = dtos.map(MedicationInput.fromDto).toList();
  //   _medicationsToDelete.clear();
  // }

  void loadFromDto(List<ManualInputDto> dtos) {
    medications = dtos.map(MedicationInput.fromDto).toList();
    _toDelete.clear();

    _originalById
      ..clear()
      ..addEntries(medications.where((m) => m.isSavedInDatabase).map((m) => MapEntry(m.id, m)));
  }

  void add(String name, int amount, DateTime time) {
    medications = [...medications, MedicationInput(name: name, amount: amount, time: time)];
  }

  void removeById(String id) {
    final med = medications.where((m) => m.id == id).firstOrNull;
    if (med == null) return;

    if (med.isSavedInDatabase) _toDelete.add(id);
    medications = medications.where((m) => m.id != id).toList();
  }

  // void removeAt(String id) {
  //   final med = medications.firstWhere((m) => m.id == id);
  //   if (med.isSavedInDatabase) _medicationsToDelete.add(med.id);
  //   medications = medications.where((m) => m.id != id).toList();
  // }

  void updateById(String id, String name, int amount, DateTime time) {
    final index = medications.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final old = medications[index];
    final updated = old.copyWith(name: name, amount: amount, time: time);

    final copy = List<MedicationInput>.from(medications);
    copy[index] = updated;
    medications = copy;
  }

  // void updateMedication(String originalId, String name, int amount, DateTime time) {
  //   final index = medications.indexWhere((m) => m.id == originalId);
  //   if (index == -1) return;
  //
  //   final oldMed = medications[index];
  //   if (oldMed.isSavedInDatabase) _medicationsToDelete.add(oldMed.id);
  //
  //   final newMed = MedicationInput(name: name, amount: amount, time: time);
  //   final copy = List<MedicationInput>.from(medications);
  //   copy[index] = newMed;
  //   medications = copy;
  // }

  List<ManualInputDto> buildCreateRequest() {
    return medications.where((m) => !m.isSavedInDatabase).map((m) => m.toDto()).toList();
  }

  List<ManualInputDto> buildUpdateRequest() {
    final updates = <ManualInputDto>[];

    for (final m in medications.where((m) => m.isSavedInDatabase)) {
      if (!_isSavedAndChanged(m)) continue;

      final medValue = MedicationValueInput(name: m.name, amount: m.amount);

      updates.add(
        ManualInputDto(
          id: m.id,
          type: 'MEDICATION',
          dateFrom: m.time,
          medication: medValue
        ),
      );
    }

    return updates;
  }

  void commit() {
    _toDelete.clear();
    _originalById
      ..clear()
      ..addEntries(
        medications
            .where((m) => m.isSavedInDatabase)
            .map((m) => MapEntry(m.id, m)),
      );
  }

  // void clear() {
  //   medications = [];
  //   _medicationsToDelete.clear();
  // }

  void clear() {
    medications = [];
    _toDelete.clear();
    _originalById.clear();
  }

  bool _isSavedAndChanged(MedicationInput current) {
    if (!current.isSavedInDatabase) return false;

    final original = _originalById[current.id];
    if (original == null) return false;

    return original.name != current.name ||
        original.amount != current.amount ||
        original.time != current.time;
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
