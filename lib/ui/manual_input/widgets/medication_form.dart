import 'package:diabits_mobile/ui/shared/field_validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';

/// A form for users to manually input medication details.
///
/// This widget includes fields for medication name, amount, and the time it was taken.
/// It provides validation and a button to add the medication to medication list.
class MedicationForm extends StatefulWidget {
  const MedicationForm({super.key});

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

/// State management for the [MedicationForm].
///
/// Handles form validation, controller lifecycle, and user interactions
/// like picking a time and submitting the form.
class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();

  /// Builds the user interface for the medication form.
  ///
  /// Initializes the time controller with the current time if it's empty.
  /// Lays out the text fields for name, amount, and time, along with the "Add" button.
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManualInputViewModel>();
    final editingMed = vm.editingMedication;

    if (editingMed != null && _nameController.text.isEmpty && _amountController.text.isEmpty) {
      _nameController.text = editingMed.name;
      _amountController.text = editingMed.amount.toString();
      _selectedTime = TimeOfDay.fromDateTime(editingMed.time);
      _timeController.text = _selectedTime.format(context);
    }

    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime.format(context);
    }

    return AlertDialog(
      title: Text(editingMed != null ? "Edit Medication" : "Add Medication"),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Medication Name",
                border: OutlineInputBorder(),
              ),
              validator: FieldValidators.requiredValidator,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Amount", border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: FieldValidators.integerValidator,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Taken at",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    onTap: _pickTime,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addMedication,
                    icon: Icon(editingMed != null ? Icons.check : Icons.add),
                    label: Text(editingMed != null ? "Update" : "Add medication"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                if (editingMed != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _nameController.clear();
                      _amountController.clear();
                      vm.cancelEditing();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Validates the form and adds the new medication entry.
  ///
  /// If the form is valid, it reads the input values, creates a [DateTime] object,
  /// and calls the view model to add the medication. It then clears the input fields.
  void _addMedication() {
    final vm = context.read<ManualInputViewModel>();
    final selectedDay = vm.selectedDate;

    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text.trim();
      final amount = int.parse(_amountController.text.trim());

      final time = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      vm.addMedication(name, amount, time);

      _nameController.clear();
      _amountController.clear();
      Navigator.pop(context);
    }
  }

  /// Displays a time picker to allow the user to select a time.
  ///
  /// Updates the state with the chosen time and formats it into the time text field.
  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(context: context, initialTime: _selectedTime);
    if (pickedTime != null) {
      setState(() => _selectedTime = pickedTime);
      _timeController.text = pickedTime.format(context);
    }
  }

  /// Disposes the text editing controllers when the widget is removed from the tree.
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
