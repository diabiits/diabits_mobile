import '../../../data/manual_input/dtos/manual_input_dto.dart';
import '../../../domain/models/medication_input.dart';

/// Manages a collection of medication entries for a specific date.
///
/// Responsibilities:
/// - Maintains the current list of [MedicationInput] items.
/// - Tracks which database-backed items have been deleted ([toDeleteIds]).
/// - Determines "Dirty" state by comparing current items against the [_snapshotById].
/// - Prepares DTOs for batch operations (Create, Update, Delete).
class MedicationManager {
  /// The current working list of medications shown in the UI.
  List<MedicationInput> medications = [];

  /// IDs of medications that exist in the database but were removed by the user.
  final Set<int> _toDeleteIds = {};
  List<int> get toDeleteIds => List.unmodifiable(_toDeleteIds);

  /// A snapshot of medications as they exist in the database, used for diffing.
  final Map<int, MedicationInput> _snapshotById = {};

  /// Returns true if the user has added, removed, or modified any medications.
  bool get isDirty =>
      _toDeleteIds.isNotEmpty ||
      medications.any((m) => !m.isSavedInDatabase) ||
      medications.any(_hasChangedSinceSnapshot);

  /// Populates the manager with fresh data from the database.
  void loadFromDto(List<ManualInputDto> dtos) {
    medications = dtos.map(MedicationInput.fromDto).toList();
    _toDeleteIds.clear();

    _snapshotById
      ..clear()
      ..addEntries(medications.where((m) => m.isSavedInDatabase).map((m) => MapEntry(m.id, m)));
  }

  /// Adds a new medication entry (not yet in database).
  void add({
    required String name,
    required double quantity,
    required double strengthValue,
    required StrengthUnit strengthUnit,
    required DateTime time,
  }) {
    medications = [
      ...medications,
      MedicationInput(
        name: name,
        quantity: quantity,
        strengthValue: strengthValue,
        strengthUnit: strengthUnit,
        time: time,
      ),
    ];
  }

  /// Removes a medication from the list. If it was in the DB, tracks it for deletion.
  void removeById(int id) {
    final med = medications.where((m) => m.id == id).singleOrNull;
    if (med == null) return;

    if (med.isSavedInDatabase) _toDeleteIds.add(id);
    medications = medications.where((m) => m.id != id).toList();
  }

  /// Updates the values of an existing entry in the current list.
  void update({
    required int id,
    required String name,
    required double quantity,
    required double strengthValue,
    required StrengthUnit strengthUnit,
    required DateTime time,
  }) {
    final index = medications.indexWhere((m) => m.id == id);
    if (index == -1) return;

    final updated = medications[index].copyWith(
      name: name,
      quantity: quantity,
      strengthValue: strengthValue,
      strengthUnit: strengthUnit,
      time: time,
    );

    final newList = List<MedicationInput>.from(medications);
    newList[index] = updated;
    medications = newList;
  }

  /// Returns DTOs for items created during this session.
  List<ManualInputDto> buildCreateRequests() =>
      medications.where((m) => !m.isSavedInDatabase).map((m) => m.toDto()).toList();

  /// Returns DTOs for database items that were modified.
  List<ManualInputDto> buildUpdateRequests() {
    return medications.where(_hasChangedSinceSnapshot).map((m) => m.toDto()).toList();
  }

  /// Resets the manager to an empty state.
  void clear() {
    medications = [];
    _toDeleteIds.clear();
    _snapshotById.clear();
  }

  bool _hasChangedSinceSnapshot(MedicationInput current) {
    if (!current.isSavedInDatabase) return false;
    final original = _snapshotById[current.id];
    if (original == null) return false;

    return original.name != current.name ||
        original.quantity != current.quantity ||
        original.strengthValue != current.strengthValue ||
        original.strengthUnit != current.strengthUnit ||
        original.time != current.time;
  }
}
