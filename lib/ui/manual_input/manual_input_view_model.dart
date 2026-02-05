import 'package:diabits_mobile/data/manual_input/dtos/manual_input_request.dart';
import 'package:diabits_mobile/data/manual_input/manual_input_repository.dart';
import 'package:flutter/material.dart';

import '../../domain/models/medication_input.dart';
import 'managers/medication_manager.dart';
import 'managers/menstruation_manager.dart';

/// A view model for the manual input screen that handles the business logic for
/// menstruation and medication tracking.
///
/// It uses a [ManualInputRepository] to fetch and save data, and it notifies its listeners when the data changes.
/// It also manages loading states to give visual feedback to the user.
class ManualInputViewModel extends ChangeNotifier {
  final ManualInputRepository _inputRepo;
  final MenstruationManager menstruationManager = MenstruationManager();
  final MedicationManager medicationManager = MedicationManager();

  ManualInputViewModel({required ManualInputRepository inputRepo}) : _inputRepo = inputRepo;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;
  bool get hasUnsavedChanges => menstruationManager.isDirty || medicationManager.isDirty;
  bool isLoading = false;

  MedicationInput? _editingMedication;
  MedicationInput? get editingMedication => _editingMedication;

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
    final response = await _inputRepo.getManualInputForDay(_selectedDate);
    if (response != null) {
      menstruationManager.loadFromDto(response.menstruation);
      medicationManager.loadFromDto(response.medications);
    }
    notifyListeners();
  }

  void setSelectedDate(DateTime newDate) {
    _selectedDate = newDate;
    clear();
    loadDataForSelectedDate();
  }

  /// Changes the selected day by the given number of days, clears existing data, and fetches new data.
  /// Used by [DateSelector] to navigate to the previous or next day via the chevron buttons.
  void changeDate(int days) {
    _selectedDate = _selectedDate.add(Duration(days: days));
    clear();
    loadDataForSelectedDate();
  }

  // /// Adds a new medication entry via the [MedicationManager].
  // void addMedication(String name, int amount, DateTime time) {
  //   medicationManager.add(name, amount, time);
  //   notifyListeners();
  // }

  /// Removes a medication entry by its ID via the [MedicationManager].
  void removeMedicationAt(String id) {
    medicationManager.removeAt(id);
    notifyListeners();
  }

  /// Updates the menstruation status via the [MenstruationManager].
  void setIsMenstruating(bool isMenstruating) {
    menstruationManager.setIsMenstruating(isMenstruating, selectedDate);
    notifyListeners();
  }

  /// Updates the menstruation flow via the [MenstruationManager].
  void setFlow(String value) {
    menstruationManager.setFlow(value);
    notifyListeners();
  }

  /// Clears all temporary data from the state managers.
  void clear() {
    menstruationManager.clear();
    medicationManager.clear();
  }

  /// Collects all pending changes from the state managers and submits them to the repository.
  Future<void> submit() async {
    isLoading = true;
    notifyListeners();

    try {
      final futures = <Future>[];

      // Collect deletions
      for (final id in medicationManager.medicationsToDelete) {
        futures.add(_inputRepo.deleteManualInput(id));
      }
      final menstruationDeleteId = menstruationManager.idToDelete;
      if (menstruationDeleteId != null) {
        futures.add(_inputRepo.deleteManualInput(menstruationDeleteId));
      }

      // Collect updates
      final menstruationUpdate = menstruationManager.updateDto;
      if (menstruationUpdate != null) {
        futures.add(_inputRepo.updateManualInput(menstruationUpdate));
      }

      // Execute deletions and updates in parallel
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }

      // Submit new entries in batch
      final request = _buildRequest();
      if (request.medications.isNotEmpty || request.menstruations.isNotEmpty) {
        await _inputRepo.submitManualInput(request);
      }

      // Commit changes locally and refresh
      menstruationManager.commit();
      // medicationManager.commit(); // TODO implement commit in MedicationManager too
      await loadDataForSelectedDate();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// A private helper method to construct the manual input request from manager data.
  ManualInputRequest _buildRequest() {
    return ManualInputRequest(
      medications: medicationManager.buildCreateRequest(),
      menstruations: menstruationManager.buildCreateRequest(),
    );
  }
}
