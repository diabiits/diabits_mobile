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

  MedicationInput? _editingMedication;
  MedicationInput? get editingMedication => _editingMedication;

  int _loadToken = 0;

  void startEditing(MedicationInput medication) {
    _editingMedication = medication;
    notifyListeners();
  }

  void cancelEditing() {
    _editingMedication = null;
    notifyListeners();
  }

  void addMedication(String name, int amount, DateTime time) {
    if (_editingMedication != null) {
      medicationManager.updateMedication(_editingMedication!.id, name, amount, time);
      _editingMedication = null;
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
    medicationManager.removeAt(id);
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
    _editingMedication = null;
  }

  Future<void> submit() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = <Future>[];

      for (final id in medicationManager.medicationsToDelete) {
        futures.add(_inputRepo.deleteManualInput(id));
      }

      final menstruationDeleteId = menstruationManager.idToDelete;
      if (menstruationDeleteId != null) {
        futures.add(_inputRepo.deleteManualInput(menstruationDeleteId));
      }

      final menstruationUpdate = menstruationManager.updateDto;
      if (menstruationUpdate != null) {
        futures.add(_inputRepo.updateManualInput(menstruationUpdate));
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      final request = _buildRequest();
      if (request.medications.isNotEmpty || request.menstruations.isNotEmpty) {
        await _inputRepo.submitManualInput(request);
      }

      menstruationManager.commit();
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
