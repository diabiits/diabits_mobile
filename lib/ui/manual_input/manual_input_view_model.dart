import 'package:diabits_mobile/data/manual_input/dtos/manual_input_request.dart';
import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:flutter/material.dart';

import '../../domain/models/medication_input.dart';
import 'managers/medication_manager.dart';
import 'managers/menstruation_manager.dart';

class ManualInputViewModel extends ChangeNotifier {
  final ManualInputRepository _inputRepo;
  final MenstruationManager menstruationManager = MenstruationManager();
  final MedicationManager medicationManager = MedicationManager();

  ManualInputViewModel({required ManualInputRepository inputRepo}) : _inputRepo = inputRepo;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool get hasUnsavedChanges => menstruationManager.isDirty || medicationManager.isDirty;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  MedicationInput? _editingMedicationId;
  MedicationInput? get editingMedication => _editingMedicationId;

  int _loadToken = 0;

  void startEditing(MedicationInput medication) {
    _editingMedicationId = medication;
    notifyListeners();
  }

  void cancelEditing() {
    _editingMedicationId = null;
    notifyListeners();
  }

  //TODO In manager or here?
  void saveMedication(String name, int amount, DateTime time) {
    if (_editingMedicationId != null) {
      medicationManager.updateById(_editingMedicationId!.id, name, amount, time);
      _editingMedicationId = null;
    } else {
      medicationManager.add(name, amount, time);
    }
    notifyListeners();
  }

  Future<void> loadDataForSelectedDate() async {
    final token = ++_loadToken;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _inputRepo.getManualInputForDay(_selectedDate);

      if (token != _loadToken) return;

      if (response != null) {
        menstruationManager.loadFromDto(response.menstruation);
        medicationManager.loadFromDto(response.medications);
      } else {
        clear();
      }
    } finally {
      if (token == _loadToken) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> setSelectedDate(DateTime newDate) async {
    _selectedDate = newDate;
    clear();
    notifyListeners();
    await loadDataForSelectedDate();
  }

  Future<void> changeDate(int days) async {
    _selectedDate = _selectedDate.add(Duration(days: days));
    clear();
    notifyListeners();
    await loadDataForSelectedDate();
  }

  void removeMedicationAt(String id) {
    medicationManager.removeById(id);
    notifyListeners();
  }

  void setIsMenstruating(bool isMenstruating) {
    menstruationManager.setIsMenstruating(isMenstruating, selectedDate);
    notifyListeners();
  }

  void setFlow(String value) {
    menstruationManager.setFlow(value);
    notifyListeners();
  }

  void clear() {
    menstruationManager.clear();
    medicationManager.clear();
    _editingMedicationId = null;
  }

  Future<void> submit() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = <Future>[];

      // Medication deletes
      for (final id in medicationManager.medicationsToDelete) {
        futures.add(_inputRepo.deleteManualInput(id));
      }

      // Menstruation delete
      final menstruationDeleteId = menstruationManager.idToDelete;
      if (menstruationDeleteId != null) {
        futures.add(_inputRepo.deleteManualInput(menstruationDeleteId));
      }

      // Menstruation update
      final menstruationUpdate = menstruationManager.updateDto;
      if (menstruationUpdate != null) {
        futures.add(_inputRepo.updateManualInput(menstruationUpdate));
      }

      // Medication updates
      for (final dto in medicationManager.buildUpdateRequest()) {
        futures.add(_inputRepo.updateManualInput(dto));
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      // Create (new items)
      final request = _buildRequest();
      if (request.medications.isNotEmpty || request.menstruations.isNotEmpty) {
        await _inputRepo.submitManualInput(request);
      }

      // Mark current state as persisted baseline
      menstruationManager.commit();
      medicationManager.commit();

      // Refresh from backend
      await loadDataForSelectedDate();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ManualInputRequest _buildRequest() {
    return ManualInputRequest(
      medications: medicationManager.buildCreateRequest(),
      menstruations: menstruationManager.buildCreateRequest(),
    );
  }
}
