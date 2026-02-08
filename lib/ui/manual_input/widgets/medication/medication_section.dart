import 'package:flutter/material.dart';

import 'medication_list.dart';

class MedicationSection extends StatelessWidget {
  final VoidCallback onAdd;

  const MedicationSection({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final outerColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65);
    final innerColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.40);

    return Material(
      color: outerColor,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Medications', style: theme.textTheme.titleMedium),
                  ),
                  IconButton(
                    tooltip: 'Add medication',
                    onPressed: onAdd,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: innerColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const MedicationList(embedded: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}