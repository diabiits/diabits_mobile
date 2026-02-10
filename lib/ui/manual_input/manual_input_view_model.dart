import 'package:diabits_mobile/data/network/requests/manual_input_request.dart';
import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:flutter/material.dart';

import '../../domain/models/medication_input.dart';
import 'managers/medication_manager.dart';
import 'managers/menstruation_manager.dart';

/// Coordinates the state for the Manual Input screen.
///
/// Responsibilities:
/// - Manages UI-specific state (Loading indicators, Selected Date).
/// - Manages the "Editing" context (which item is currently focused).
/// - Orchestrates multiple [Managers] to perform a unified [submit] operation.
/// - Communicates with the [ManualInputRepository] for data I/O.
class ManualInputViewModel extends ChangeNotifier {
  final ManualInputRepository _inputRepo;
  final MenstruationManager menstruationManager = MenstruationManager();
  final MedicationManager medicationManager = MedicationManager();

  ManualInputViewModel({required ManualInputRepository inputRepo}) : _inputRepo = inputRepo;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// The medication currently being edited in the form, if any.
  MedicationInput? _activeEditingMedication;
  MedicationInput? get activeEditingMedication => _activeEditingMedication;

  /// Global check if any part of the screen has unsaved changes.
  bool get hasUnsavedChanges => menstruationManager.isDirty || medicationManager.isDirty;

  /// Keep track of which load operation is currently in progress.
  int _loadToken = 0;

  void startEditing(MedicationInput medication) {
    _activeEditingMedication = medication;
    notifyListeners();
  }

  void cancelEditing() {
    _activeEditingMedication = null;
    notifyListeners();
  }

  /// High-level logic to decide whether to add or update an item.
  void saveMedication({
    required String name,
    required double quantity,
    required double strengthValue,
    required StrengthUnit strengthUnit,
    required DateTime time,
  }) {
    if (_activeEditingMedication != null) {
      medicationManager.update(
        id: _activeEditingMedication!.id,
        name: name,
        quantity: quantity,
        strengthValue: strengthValue,
        strengthUnit: strengthUnit,
        time: time,
      );
      _activeEditingMedication = null;
    } else {
      medicationManager.add(
        name: name,
        quantity: quantity,
        strengthValue: strengthValue,
        strengthUnit: strengthUnit,
        time: time,
      );
    }
    notifyListeners();
  }

  /// Fetches data for the current [selectedDate] and updates managers.
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
        clearManagers();
      }
    } finally {
      if (token == _loadToken) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Pushes all changes from managers to the backend.
  Future<void> submit() async {
    _isLoading = true;
    notifyListeners();

    try {
      final futures = <Future>[];

      final deletions = [
        ...medicationManager.toDeleteIds,
        if (menstruationManager.idToDelete != null) menstruationManager.idToDelete!,
      ];
      if (deletions.isNotEmpty) {
        futures.add(_inputRepo.deleteManualInputs(ManualInputDeleteRequest(ids: deletions)));
      }

      final updates = [
        ...medicationManager.buildUpdateRequests(),
        if (menstruationManager.updateDto != null) menstruationManager.updateDto!,
      ];
      if (updates.isNotEmpty) {
        futures.add(_inputRepo.updateManualInputs(ManualInputRequest(items: updates)));
      }

      final creations = [
        ...medicationManager.buildCreateRequests(),
        if (menstruationManager.createDto != null) menstruationManager.createDto!,
      ];
      if (creations.isNotEmpty) {
        futures.add(_inputRepo.submitManualInputs(ManualInputRequest(items: creations)));
      }

      if (futures.isNotEmpty) await Future.wait(futures);

      // Refresh from backend
      await loadDataForSelectedDate();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Navigation / Date methods
  Future<void> setSelectedDate(DateTime newDate) async {
    _selectedDate = newDate;
    _isLoading = true;
    notifyListeners();
    await loadDataForSelectedDate();
  }

  Future<void> changeDate(int days) async =>
      await setSelectedDate(_selectedDate.add(Duration(days: days)));

  // Manager related passthrough methods
  void deleteMedication(int id) {
    medicationManager.removeById(id);
    notifyListeners();
  }

  void toggleMenstruation(bool isMenstruating) {
    menstruationManager.setIsMenstruating(isMenstruating, selectedDate);
    notifyListeners();
  }

  void updateMenstruationFlow(String value) {
    menstruationManager.setFlow(value);
    notifyListeners();
  }

  void clearManagers() {
    menstruationManager.clear();
    medicationManager.clear();
    _activeEditingMedication = null;
  }
}
