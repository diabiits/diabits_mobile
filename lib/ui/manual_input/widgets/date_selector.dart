import 'package:diabits_mobile/ui/manual_input/manual_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

/// A widget that allows the user to select a day for manual data entry.
///
/// It displays the currently selected day and provides buttons to navigate to the previous or next day. It also allows picking a specific date from a calendar.
/// Before changing the date, it checks for unsaved changes and prompts the user for confirmation if necessary.
class DateSelector extends StatelessWidget {
  const DateSelector({super.key});

  /// Builds the day selector's user interface.
  ///
  /// This method constructs a row with back and forward navigation buttons,
  /// and a central button that displays the current date and opens a date picker on press.
  @override
  Widget build(BuildContext context) {
    final selectedDay = context.select((ManualInputViewModel vm) => vm.selectedDate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [BoxShadow(color: Color(0xffa53860), spreadRadius: 2, blurRadius: 6)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 10,
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xfff6f4f0)),
              onPressed: () => _changeDay(context, -1),
            ),
          ),
          Expanded(
            flex: 25,
            child: TextButton(
              onPressed: () => _pickDate(context),
              child: Text(
                _formatDate(selectedDay),
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xfff6f4f0),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xfff6f4f0)),
              onPressed: () => _changeDay(context, 1),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats the date for display.
  ///
  /// Returns "Today" for the current date, otherwise formats it as 'd MMMM y' (e.g., 11 January 2023).
  String _formatDate(DateTime day) {
    if (DateUtils.isSameDay(day, DateTime.now())) return 'Today';
    return intl.DateFormat('d MMMM y', intl.Intl.systemLocale).format(day);
  }

  /// Handles changing the day by a given number of days (e.g., +1 or -1).
  ///
  /// Before changing the day, it checks for unsaved changes using [vm.hasUnsavedChanges].
  /// If there are unsaved changes, it shows a confirmation dialog.
  Future<void> _changeDay(BuildContext context, int days) async {
    final vm = context.read<ManualInputViewModel>();

    if (vm.hasUnsavedChanges) {
      final confirmed = await _confirmDiscardChanges(context);
      if (confirmed != true) return;
    }

    await vm.changeDate(days);
  }

  Future<void> _pickDate(BuildContext context) async {
    final vm = context.read<ManualInputViewModel>();

    if (vm.hasUnsavedChanges) {
      final confirmed = await _confirmDiscardChanges(context);
      if (confirmed != true) return;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked == null) return;
    await vm.setSelectedDate(picked);
  }

  /// Shows a confirmation dialog to the user.
  ///
  /// This dialog warns the user about unsaved changes and asks for confirmation before discarding them.
  Future<bool?> _confirmDiscardChanges(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them and switch to another day?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard changes'),
          ),
        ],
      ),
    );
  }
}
