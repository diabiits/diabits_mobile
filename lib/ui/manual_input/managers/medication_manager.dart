import '../../../data/manual_input/dtos/manual_input_dto.dart';
import '../../../domain/models/medication_input.dart';

class MedicationManager {
  List<MedicationInput> medications = [];
  final Set<String> _medicationsToDelete = {};

  List<String> get medicationsToDelete => List.unmodifiable(_medicationsToDelete);

  bool get isDirty =>
      medications.any((m) => !m.isSavedInDatabase) || _medicationsToDelete.isNotEmpty;

  void loadFromDto(List<ManualInputDto> dtos) {
    medications = dtos.map(MedicationInput.fromDto).toList();
    _medicationsToDelete.clear();
  }

  void add(String name, int amount, DateTime time) {
    medications = [...medications, MedicationInput(name: name, amount: amount, time: time)];
  }

  void removeAt(String id) {
    final med = medications.firstWhere((m) => m.id == id);
    if (med.isSavedInDatabase) _medicationsToDelete.add(med.id);
    medications = medications.where((m) => m.id != id).toList();
  }

  void updateMedication(String originalId, String name, int amount, DateTime time) {
    final index = medications.indexWhere((m) => m.id == originalId);
    if (index == -1) return;

    final oldMed = medications[index];
    if (oldMed.isSavedInDatabase) _medicationsToDelete.add(oldMed.id);

    final newMed = MedicationInput(name: name, amount: amount, time: time);
    final copy = List<MedicationInput>.from(medications);
    copy[index] = newMed;
    medications = copy;
  }

  void clear() {
    medications = [];
    _medicationsToDelete.clear();
  }

  List<ManualInputDto> buildCreateRequest() {
    return medications.where((m) => !m.isSavedInDatabase).map((m) => m.toDto()).toList();
  }
}
