import 'package:diabits_mobile/ui/shared/section_card.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/medication_input.dart';
import 'medication_list.dart';

class MedicationSection extends StatelessWidget {
  final VoidCallback onAdd;
  final void Function(MedicationInput med) onEdit;
  final void Function(int id) onDelete;

  const MedicationSection({
    super.key,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('Medications', style: theme.textTheme.titleMedium)),
              IconButton(icon: const Icon(Icons.add), onPressed: onAdd),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: SectionCard.innerColor(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: MedicationList(onEdit: onEdit, onDelete: onDelete),
            ),
          ),
        ],
      ),
    );
  }
}
