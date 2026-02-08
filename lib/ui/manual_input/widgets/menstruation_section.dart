import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';

const _flowOptions = [
  DropdownMenuItem(value: "SPOTTING", child: Text("Spotting")),
  DropdownMenuItem(value: "LIGHT", child: Text("Light")),
  DropdownMenuItem(value: "MEDIUM", child: Text("Medium")),
  DropdownMenuItem(value: "HEAVY", child: Text("Heavy")),
];

class MenstruationSection extends StatelessWidget {
  const MenstruationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isMenstruating = context.select<ManualInputViewModel, bool>(
      (vm) => vm.menstruationManager.menstruation != null,
    );

    final currentFlow = context.select<ManualInputViewModel, String?>(
      (vm) => vm.menstruationManager.menstruation?.flow,
    );

    //TODO Move to theme
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
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                children: [
                  Expanded(child: Text('Menstruation', style: theme.textTheme.titleMedium)),
                  Switch.adaptive(
                    value: isMenstruating,
                    onChanged: (value) =>
                        context.read<ManualInputViewModel>().setIsMenstruating(value),
                  ),
                ],
              ),
            ),
            if (isMenstruating && currentFlow != null)
              _FlowDropdown(
                value: currentFlow,
                backgroundColor: innerColor,
                textStyle: theme.textTheme.bodyMedium,
                onChanged: (value) => context.read<ManualInputViewModel>().setFlow(value),
              ),
          ],
        ),
      ),
    );
  }
}

class _FlowDropdown extends StatelessWidget {
  final String value;
  final Color backgroundColor;
  final TextStyle? textStyle;
  final ValueChanged<String> onChanged;

  const _FlowDropdown({
    required this.value,
    required this.backgroundColor,
    required this.textStyle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: _flowOptions,
            borderRadius: BorderRadius.circular(14),
            style: textStyle,
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}