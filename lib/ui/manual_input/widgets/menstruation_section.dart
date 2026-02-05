import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';

/// A list of dropdown menu items representing menstrual flow levels.
const _flowItems = [
  DropdownMenuItem(value: "SPOTTING", child: Text("Spotting")),
  DropdownMenuItem(value: "LIGHT", child: Text("Light")),
  DropdownMenuItem(value: "MEDIUM", child: Text("Medium")),
  DropdownMenuItem(value: "HEAVY", child: Text("Heavy")),
];

/// A widget for logging menstruation data.
///
/// This widget includes a switch to indicate if the user is menstruating
/// and a dropdown to specify the flow level.
class MenstruationSection extends StatelessWidget {
  const MenstruationSection({super.key});

  /// Builds the UI for the menstruation section.
  ///
  /// Displays a switch to toggle menstruation status and, if enabled,
  /// shows a dropdown to select the flow level.
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ManualInputViewModel>();
    final manager = vm.menstruationManager;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text("Menstruating?", style: Theme.of(context).textTheme.titleMedium),
          value: manager.menstruation != null,
          onChanged: vm.setIsMenstruating,
        ),
        if (manager.menstruation != null) ...[
          const SizedBox(height: 12),
          const _FlowDropdown(),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// A private widget that renders a dropdown for selecting menstrual flow.
class _FlowDropdown extends StatelessWidget {
  const _FlowDropdown();

  /// Builds the dropdown UI.
  ///
  /// The dropdown is wrapped in an [InputDecorator] to match the app's
  /// text field styling.
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ManualInputViewModel>();
    final manager = viewModel.menstruationManager;

    return InputDecorator(
      decoration: const InputDecoration(
        labelText: "Flow",
        border: OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          style: Theme.of(context).textTheme.bodyLarge,
          value: manager.menstruation!.flow,
          isDense: true,
          items: _flowItems,
          onChanged: (v) => {if (v != null) viewModel.setFlow(v)},
        ),
      ),
    );
  }
}
