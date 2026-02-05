import 'package:diabits_mobile/ui/manual_input/manual_input_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../manual_input_view_model.dart';

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
    final selectedDay = context.select(
      (ManualInputViewModel vm) => vm.selectedDate,
    );
    final modelView = context.read<ManualInputViewModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 10,
          child: IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black54),
            onPressed: () => _handleChangeDay(context, modelView, -1),
          ),
        ),
        Expanded(
          flex: 25,
          child: TextButton(
            onPressed: () => _pickDate(context, modelView),
            child: Text(
              _formatDate(selectedDay),
              style: const TextStyle(fontSize: 20, color: Colors.black87),
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black54),
            onPressed: () => _handleChangeDay(context, modelView, 1),
          ),
        ),
      ],
    );
  }

  /// Formats the date for display.
  ///
  /// Returns "Today" for the current date, otherwise formats it as 'd MMMM y' (e.g., 11 January 2023).
  String _formatDate(DateTime day) {
    final now = DateTime.now();
    if (day.year == now.year && day.month == now.month && day.day == now.day) {
      return "Today";
    }
    return intl.DateFormat('d MMMM y', intl.Intl.systemLocale).format(day);
  }

  /// Handles changing the day by a given number of days (e.g., +1 or -1).
  ///
  /// Before changing the day, it checks for unsaved changes using [modelView.hasUnsavedChanges].
  /// If there are unsaved changes, it shows a confirmation dialog.
  Future<void> _handleChangeDay(
    BuildContext context,
    ManualInputViewModel modelView,
    int days,
  ) async {
    if (modelView.hasUnsavedChanges) {
      final confirmed = await _showConfirmationDialog(context);
      if (confirmed ?? false) {
        modelView.changeDate(days);
      }
    } else {
      modelView.changeDate(days);
    }
  }

  /// Opens a date picker to allow the user to select a specific date.
  ///
  /// Similar to [_handleChangeDay], it checks for unsaved changes before showing the date picker.
  /// If a new date is selected, it updates the view model.
  Future<void> _pickDate(
    BuildContext context,
    ManualInputViewModel modelView,
  ) async {
    if (modelView.hasUnsavedChanges) {
      final confirmed = await _showConfirmationDialog(context);
      if (!(confirmed ?? false)) {
        return;
      }
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: modelView.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (picked != null) {
      modelView.setSelectedDate(picked);
    }
  }

  /// Shows a confirmation dialog to the user.
  ///
  /// This dialog warns the user about unsaved changes and asks for confirmation before discarding them.
  Future<bool?> _showConfirmationDialog(BuildContext context) {
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
