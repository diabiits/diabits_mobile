import '../../../data/manual_input/dtos/manual_input_dto.dart';
import '../../../data/manual_input/dtos/medication_value_input.dart';
import '../../../data/manual_input/manual_input_repository.dart';
import '../../../domain/models/medication_input.dart';

/// Manages the state of medication entries for the manual input screen.
class MedicationManager {
  List<MedicationInput> medications = [];
  final List<String> _medicationsToDelete = [];

  /// Returns a list of IDs for medications that need to be removed from the backend.
  List<String> get medicationsToDelete => List.unmodifiable(_medicationsToDelete);

  bool get isDirty =>
      medications.any((m) => !m.isSavedInDatabase) || _medicationsToDelete.isNotEmpty;

  void loadFromDto(List<ManualInputDto> dtos) {
    medications = dtos.map((m) => MedicationInput.fromDto(m)).toList();
    _medicationsToDelete.clear();
  }

  void add(String name, int amount, DateTime time) {
    medications = [...medications, MedicationInput(name: name, amount: amount, time: time)];
  }

  void removeAt(String id) {
    final med = medications.firstWhere((med) => med.id == id);
    if (med.isSavedInDatabase) {
      _medicationsToDelete.add(med.id);
    }
    medications = medications.where((med) => med.id != id).toList();
  }


  void updateMedication(String originalId, String name, int amount, DateTime time) {
    final index = medications.indexWhere((m) => m.id == originalId);
    if (index != -1) {
      final oldMed = medications[index];

      // If it was already in the DB, track it for deletion
      if (oldMed.isSavedInDatabase) {
        _medicationsToDelete.add(oldMed.id);
      }

      // Replace with a new unsaved entry (effectively an update via delete + create)
      final newMed = MedicationInput(name: name, amount: amount, time: time);
      medications = List.from(medications)
        ..removeAt(index)
        ..insert(index, newMed);
    }
  }

  /// Adds deletion futures to a list of futures for batch processing.
  ///
  /// This method is used during the submission process to collect all the necessary
  /// deletion operations that need to be sent to the repository.
  // void addSubmitFutures(ManualInputRepository repo, List<Future> futures) {
  //   for (final id in _medicationsToDelete) {
  //     futures.add(repo.deleteManualInput(id));
  //   }
  // }

  /// Clears all medication data, including the list of medications to delete.
  void clear() {
    medications = [];
    _medicationsToDelete.clear();
  }

  /// Builds a list of DTOs for medications that need to be created in the backend.
  ///
  /// This method filters out medications that are already saved in the database
  /// and maps the new ones to [ManualInputDto] objects.
  List<ManualInputDto> buildCreateRequest() {
    return medications.where((m) => !m.isSavedInDatabase).map((m) => m.toDto()).toList();
  }
}
