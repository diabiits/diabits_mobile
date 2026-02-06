import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';
import 'medication_form.dart';

class MedicationList extends StatelessWidget {
  final bool embedded;

  const MedicationList({super.key, this.embedded = false});

  Future<void> _openEditSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        top: false,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: MedicationForm(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final meds = context.select(
          (ManualInputViewModel vm) => vm.medicationManager.medications,
    );

    if (meds.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          'No medications logged yet',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      );
    }

    final sorted = [...meds]..sort((a, b) => a.time.compareTo(b.time));

    final list = ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 1,
        color: theme.dividerColor.withValues(alpha: 0.30),
      ),
      itemBuilder: (_, index) {
        final med = sorted[index];

        return Dismissible(
          key: ValueKey(med.id),
          direction: DismissDirection.horizontal,

          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: theme.colorScheme.secondary,
            child: const Icon(Icons.edit, color: Colors.white),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: theme.colorScheme.error,
            child: const Icon(Icons.delete, color: Colors.white),
          ),

          confirmDismiss: (direction) async {
            final vm = context.read<ManualInputViewModel>();

            if (direction == DismissDirection.startToEnd) {
              vm.startEditing(med);
              await _openEditSheet(context);
              return false; // edit does not dismiss
            }

            return direction == DismissDirection.endToStart; // delete dismisses
          },

          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              context.read<ManualInputViewModel>().removeMedicationAt(med.id);
            }
          },

          child: InkWell(
            onTap: () async {
              final vm = context.read<ManualInputViewModel>();
              vm.startEditing(med);
              await _openEditSheet(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(DateFormat.Hm().format(med.time), style: theme.textTheme.labelLarge),
                        const SizedBox(height: 4),
                        Text('${med.name} (${med.amount})', style: theme.textTheme.bodyLarge),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        );

      },
    );

    if (embedded) return list;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: list,
      ),
    );
  }
}
