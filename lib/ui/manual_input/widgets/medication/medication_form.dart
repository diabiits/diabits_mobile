import 'package:diabits_mobile/ui/shared/field_validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/medication_input.dart';
import '../../manual_input_view_model.dart';

//TODO Blink of old amount value and current timestamp on edit.
//TODO Fix modal being in safe area on bottom
class MedicationForm extends StatefulWidget {
  final MedicationInput? initial; //TODO get from vm?

  const MedicationForm({super.key, this.initial});

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _timeController = TextEditingController();

  late TimeOfDay _selectedTime;
  late final bool _isEdit;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;
    _isEdit = initial != null;

    if (initial != null) {
      _nameController.text = initial.name;
      _amountController.text = initial.amount.toString();
      _selectedTime = TimeOfDay.fromDateTime(initial.time);
    } else {
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timeController.text.isEmpty) {
      _timeController.text = _selectedTime.format(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? 'Edit medication' : 'Add medication';
    final actionText = _isEdit ? 'Update' : 'Add';
    final actionIcon = _isEdit ? Icons.check : Icons.add;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              mainAxisSize: .min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Medication name'),
                  validator: FieldValidators.requiredValidator,
                  textInputAction: .next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: .number,
                  validator: FieldValidators.integerValidator,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Taken at',
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
                  icon: Icon(actionIcon),
                  label: Text(actionText),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<ManualInputViewModel>();
    final selectedDay = vm.selectedDate;

    final name = _nameController.text.trim();
    final amount = int.parse(_amountController.text.trim());

    final time = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    vm.saveMedication(name, amount, time);
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
