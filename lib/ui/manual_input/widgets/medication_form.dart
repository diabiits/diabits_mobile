import 'package:diabits_mobile/ui/shared/field_validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';

class MedicationForm extends StatefulWidget {
  const MedicationForm({super.key});

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _prefilledForId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final vm = context.read<ManualInputViewModel>();
    final editing = vm.editingMedication;
    final id = editing?.id;

    if (id != null && _prefilledForId != id) {
      _prefilledForId = id;
      _nameController.text = editing!.name;
      _amountController.text = editing.amount.toString();
      _selectedTime = TimeOfDay.fromDateTime(editing.time);
      _timeController.text = _selectedTime.format(context);
    }

    if (id == null && _prefilledForId != null) {
      _prefilledForId = null;
      _nameController.clear();
      _amountController.clear();
      _selectedTime = TimeOfDay.now();
      _timeController.text = _selectedTime.format(context);
    }

    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManualInputViewModel>();
    final editingMed = vm.editingMedication;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            editingMed != null ? 'Edit medication' : 'Add medication',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medication name',
                    border: OutlineInputBorder(),
                  ),
                  validator: FieldValidators.requiredValidator,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: FieldValidators.integerValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Taken at',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  onTap: _pickTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    context.read<ManualInputViewModel>().cancelEditing();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _submit,
                  icon: Icon(editingMed != null ? Icons.check : Icons.add),
                  label: Text(editingMed != null ? 'Update' : 'Add'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submit() {
    final vm = context.read<ManualInputViewModel>();
    final selectedDay = vm.selectedDate;

    if (!(_formKey.currentState?.validate() ?? false)) return;

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
    Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked == null) return;

    setState(() => _selectedTime = picked);
    _timeController.text = picked.format(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
