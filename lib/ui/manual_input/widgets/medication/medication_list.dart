import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/medication_input.dart';
import '../../manual_input_view_model.dart';
import 'medication_form.dart';

class MedicationList extends StatelessWidget {
  final bool embedded;

  const MedicationList({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final meds = context.select<ManualInputViewModel, List<MedicationInput>>((vm) {
      final list = vm.medicationManager.medications;
      return [...list]..sort((a, b) => a.time.compareTo(b.time));
    });

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
      itemBuilder: (context, index) {
        final med = meds[index];

        return Dismissible(
          key: ValueKey(med.id),
          direction: DismissDirection.startToEnd,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: theme.colorScheme.primary,
            child: const Icon(Icons.delete_forever, color: Colors.white),
          ),
          onDismissed: (_) => context.read<ManualInputViewModel>().removeMedicationAt(med.id),

          //TODO Add isDirty check here as well?
          child: InkWell(
            onTap: () async {
              final vm = context.read<ManualInputViewModel>();
              vm.startEditing(med);

              try {
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  useSafeArea: true,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: MedicationForm(initial: med),
                  ),
                );
              } finally {
                vm.cancelEditing();
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
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
  }
}
