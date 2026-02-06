import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';
import '../manual_input_screen.dart';

//TODO Fix overflow
const _flowItems = [
  _FlowOption(value: "SPOTTING", label: "Spotting"),
  _FlowOption(value: "LIGHT", label: "Light"),
  _FlowOption(value: "MEDIUM", label: "Medium"),
  _FlowOption(value: "HEAVY", label: "Heavy"),
];

class MenstruationInlineTile extends StatelessWidget {
  final VoidCallback onPickFlow;

  const MenstruationInlineTile({super.key, required this.onPickFlow});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManualInputViewModel>();
    final manager = vm.menstruationManager;

    final isMenstruating = manager.menstruation != null;
    final flow = manager.menstruation?.flow;

    final flowLabel = _flowItems.firstWhere(
          (x) => x.value == flow,
      orElse: () => const _FlowOption(value: "MEDIUM", label: "Medium"),
    ).label;

    return ActionTile(
      title: 'Menstruation',
      subtitle: isMenstruating ? 'Flow: $flowLabel' : 'Not menstruating',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch.adaptive(
            value: isMenstruating,
            onChanged: (value) => vm.setIsMenstruating(value),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Pick flow',
            onPressed: isMenstruating ? onPickFlow : null,
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      onTap: () {
        vm.setIsMenstruating(!isMenstruating);
      },
    );
  }
}

class MenstruationFlowSheet extends StatelessWidget {
  const MenstruationFlowSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManualInputViewModel>();
    final manager = vm.menstruationManager;
    final isMenstruating = manager.menstruation != null;

    final current = manager.menstruation?.flow ?? "MEDIUM";

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Flow', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final option in _flowItems)
          RadioListTile<String>(
            value: option.value,
            groupValue: current,
            onChanged: isMenstruating ? (v) => vm.setFlow(v!) : null,
            title: Text(option.label),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ),
      ],
    );

  }
}

class _FlowOption {
  final String value;
  final String label;

  const _FlowOption({required this.value, required this.label});
}
