import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/medication_input.dart';
import '../../manual_input_view_model.dart';

class MedicationList extends StatelessWidget {
  final void Function(MedicationInput med) onEdit;
  final void Function(int id) onDelete;

  const MedicationList({super.key, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final meds = context.select<ManualInputViewModel, List<MedicationInput>>((vm) {
      final list = vm.medicationManager.medications;
      return [...list]..sort((a, b) => a.time.compareTo(b.time));
    });

    if (meds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'No medications logged yet',
          textAlign: .center,
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      padding: .zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meds.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: 8,
        endIndent: 8,
        color: theme.dividerColor.withValues(alpha: 0.3),
      ),
      itemBuilder: (_, index) {
        final med = meds[index];

        return Dismissible(
          key: ValueKey(med.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12),
            color: theme.colorScheme.primary,
            child: const Icon(Icons.delete, color: Color(0xfff6f4f0)),
          ),
          onDismissed: (_) => onDelete(med.id),
          child: ListTile(
            title: Text(med.name),
            subtitle: Text('${med.amount} • ${DateFormat.Hm().format(med.time)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onEdit(med),
          ),
        );
      },
    );
  }
}