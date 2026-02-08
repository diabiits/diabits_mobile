import 'package:flutter/material.dart';

import '../../../../domain/models/medication_input.dart';
import 'medication_list.dart';

class MedicationSection extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(MedicationInput med) onEdit;
  final void Function(String id) onDelete;

  const MedicationSection({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

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
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                const Expanded(child: Text('Medications')),
                IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
              ],
            ),
            Container(
              decoration: BoxDecoration(color: innerColor, borderRadius: BorderRadius.circular(14)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: MedicationList(onEdit: onEdit, onDelete: onDelete),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
