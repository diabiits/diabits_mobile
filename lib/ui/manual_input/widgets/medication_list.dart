import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';
import 'medication_form.dart';

/// A widget that displays a list of medications for the selected day.
///
/// It listens to the [ManualInputViewModel] for changes and updates the UI accordingly.
class MedicationList extends StatelessWidget {
  const MedicationList({super.key});

  /// Builds the list of medication entries.
  ///
  /// If there are no medications, it displays "No medications added yet".
  /// Otherwise, it shows a list of [ListTile] widgets, each representing a medication entry.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<ManualInputViewModel>();
    final manager = vm.medicationManager;

    if (manager.medications.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text("No medications added yet"),
        ),
      );
    }

    manager.medications.sort((a, b) => a.time.compareTo(b.time));

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: manager.medications.length,
      itemBuilder: (_, index) {
        final med = manager.medications[index];

        return Dismissible(
          key: ValueKey(med.id),
          background: Container(
            color: theme.colorScheme.primary,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: theme.colorScheme.secondary,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.endToStart) {
              vm.startEditing(med);
              showDialog(context: context, builder: (context) => const MedicationForm());
              return false;
            }
            return true;
          },
          onDismissed: (_) => vm.removeMedicationAt(med.id),
          child: ListTile(
            title: Text('${med.name} (${med.amount})'),
            subtitle: Text(DateFormat.Hm().format(med.time)),
          ),
        );
      },
    );
  }
}
