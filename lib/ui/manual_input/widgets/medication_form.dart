import 'package:diabits_mobile/ui/shared/field_validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/medication_input.dart';
import '../manual_input_view_model.dart';

class MedicationForm extends StatefulWidget {
  final MedicationInput? initial;

  const MedicationForm({super.key, this.initial});

  @override
  State<MedicationForm> createState() => _MedicationFormState();
}

class _MedicationFormState extends State<MedicationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _strengthValueController = TextEditingController();
  final _timeController = TextEditingController();

  StrengthUnit _strengthUnit = StrengthUnit.mg;
  late TimeOfDay _selectedTime;
  late final bool _isEdit;

  @override
  void initState() {
    super.initState();

    final initial = widget.initial;
    _isEdit = initial != null;

    if (initial != null) {
      _nameController.text = initial.name;
      _quantityController.text = initial.quantity.toString();
      _strengthValueController.text = initial.strengthValue.toString();
      _strengthUnit = initial.strengthUnit;
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
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
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(labelText: 'Quantity'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: FieldValidators.doubleValidator,
                            textInputAction: .next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _timeController,
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: 'Taken at',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: .start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _strengthValueController,
                            decoration: const InputDecoration(labelText: 'Strength'),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: FieldValidators.doubleValidator,
                            textInputAction: .next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<StrengthUnit>(
                            initialValue: _strengthUnit,
                            decoration: const InputDecoration(labelText: 'Unit'),
                            items: StrengthUnit.values.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit.name.toUpperCase()),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => _strengthUnit = val);
                            },
                          ),
                        ),
                      ],
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
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final vm = context.read<ManualInputViewModel>();
    final selectedDay = vm.selectedDate;

    final name = _nameController.text.trim();
    final quantity = double.parse(_quantityController.text.trim());
    final strengthValue = double.parse(_strengthValueController.text.trim());

    final time = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    vm.saveMedication(
      name: name,
      quantity: quantity,
      strengthValue: strengthValue,
      strengthUnit: _strengthUnit,
      time: time,
    );
    Navigator.pop(context);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked == null) return;
    if (!mounted) return;

    setState(() => _selectedTime = picked);
    _timeController.text = picked.format(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _strengthValueController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}
